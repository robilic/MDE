//
//  AppDelegate.m
//  MDE
//
//  Created by robert on 4/21/20.
//  Copyright © 2020 local. All rights reserved.
//

#import "AppDelegate.h"

#include <stdio.h>
#include <errno.h>

#include "mde_config.h"
#include "wadfile.h"
#include "editor.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

Thing *things;
LineDef *linedefs;
SideDef *sidedefs;
Vertex *vertexes;

Texture *textures;
Palette *palette;
Sprite *sprites;

unsigned char **sprite_images;
int TARGET_SPRITE;

SEG *segs;
SSector *ssectors;
Node *nodes;
Sector *sectors;

int things_count, linedefs_count, sidedefs_count, vertexes_count, sprites_count, textures_count;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    FILE *wadFile;
    WADFileHeader header;
    WADFileDirectoryEntry *directory;
    int textures_pointer = 0;
    int sprites_pointer = 0;

    textures_count = 0;
    sprites_count = 0;

    wadFile = fopen(WADFILE_PATH, "r");
    
    if (wadFile == NULL) {
        NSLog(@".WAD file not found :(");
        NSLog(@"errno = %d", errno);
        
        exit(0);
    }

    fread(&header, sizeof(WADFileHeader), 1, wadFile);
    printf("\nWAD file type: %c%c%c%c, dirsize: %d, dirstart: %d\n", header.type[0], header.type[1], header.type[2], header.type[3], header.dirsize, header.dirstart);
    printf("Directory entries: %d, total size: %lu\n", header.dirsize, header.dirsize * sizeof(WADFileDirectoryEntry));
    
    directory = malloc(header.dirsize * sizeof(WADFileDirectoryEntry));
    fseek(wadFile, header.dirstart, SEEK_SET);
    fread(directory, sizeof(WADFileDirectoryEntry), header.dirsize, wadFile);
    
    // find the desired level and load the data for it
    for (int i = 0; i < header.dirsize; i++) {
        if (!strncmp("E1M6", directory[i].name, 4)) {
            // printf("\nFound it! Entry #%d %d %d\n", i, directory[i].start, directory[i].size);
            // fread(void *restrict __ptr, size_t __size, size_t __nitems, FILE *restrict __stream)
            // printf("THINGS struct is %lu bytes each\n", sizeof(Thing));
            // printf("THINGS start at %d and consist of %d bytes\n", directory[i+1].start, directory[i+1].size);
            fseek(wadFile, directory[i+1].start, SEEK_SET);
            things = malloc(directory[i+1].size);
            things_count = directory[i+1].size / sizeof(Thing);
            fread(things, sizeof(Thing), directory[i+1].size / sizeof(Thing), wadFile);

            fseek(wadFile, directory[i+2].start, SEEK_SET);
            linedefs = malloc(directory[i+2].size);
            linedefs_count = directory[i+2].size / sizeof(LineDef);
            fread(linedefs, sizeof(LineDef), directory[i+2].size / sizeof(LineDef), wadFile);

            fseek(wadFile, directory[i+3].start, SEEK_SET);
            sidedefs = malloc(directory[i+3].size);
            sidedefs_count = directory[i+3].size / sizeof(SideDef);
            fread(sidedefs, sizeof(SideDef), directory[i+3].size / sizeof(SideDef), wadFile);

            fseek(wadFile, directory[i+4].start, SEEK_SET);
            vertexes = malloc(directory[i+4].size);
            vertexes_count = directory[i+4].size / sizeof(Vertex);
            fread(vertexes, sizeof(Vertex), directory[i+4].size / sizeof(Vertex), wadFile);
        }
        //printf("%.*s ", 8, directory[i].name);
    }
    printf("Loaded %d things, %d linedefs, %d sidedefs, %d vertexes\n", things_count, linedefs_count, sidedefs_count, vertexes_count);
    
    //
    // load color palette
    for (int i = 0; i < header.dirsize; i++) {
        if (!strncmp("PLAYPAL", directory[i].name, 7)) {
            //printf("Found PLAYPAL! Entry #%d %d %d\n", i, directory[i].start, directory[i].size);
            palette = malloc(sizeof(char) * 768); // we only need the first palette
            fseek(wadFile, directory[i].start, SEEK_SET);
            fread(palette, 768, 1, wadFile);
            break;
        }
    }
    /*
    printf("Palette dump:\n");
    for (int i = 0; i < 768; i += 3) {
        printf("%d: %x %x %x\n", i/3, palette[i/3].r, palette[i/3].g, palette[i/3].b);
    }
    */
    
    //
    // load floor and ceiling textures, count them first. find the start of textures
    for (int i = 0; i < header.dirsize; i++) {
        if (!strncmp("F1_START", directory[i].name, 7)) {
            //printf("\nFound it! Entry #%d %d %d\n", i, directory[i].start, directory[i].size);
            textures_pointer = i + 1;
            break;
        }
    }

    // go through the directory until we get to the end of the textures
    // TODO: why count these when we can check for this as we read them?
    for (int i = textures_pointer; i < header.dirsize; i++) {
        if (!strncmp("F1_END", directory[i].name, 6)) {
            break;
        }
        textures_count = i - textures_pointer;
    }

    // printf("Next entry is %.*s\n", 8, directory[textures_pointer].name);
    printf("Found %d floor/ceiling textures\n", textures_count);

    fseek(wadFile, directory[textures_pointer].start, SEEK_SET);
    textures = malloc(sizeof(Texture) * textures_count);
    for (int i = 0; i < textures_count; i++) {
        // copy the name from the directory to the textures structure
        memcpy(textures[i].name, directory[textures_pointer + i].name, 8);
        // now the image data
        fread(textures[i].data, 4096, 1, wadFile);
    }

    // load sprites
    for (int i = 0; i < header.dirsize; i++) {
        if (!strncmp("S_START", directory[i].name, 7)) {
            sprites_pointer = i + 1;
            break;
        }
    }
    for (int i = sprites_pointer; i < header.dirsize; i++) {
        if (!strncmp("S_END", directory[i].name, 5)) {
            break;
        }
        sprites_count = i - sprites_pointer;
    }
    printf("Sprites pointer is %d, %d sprites found!\n", sprites_pointer, sprites_count);
    // read all the sprite headers
    sprites = calloc(1, sizeof(Sprite) * sprites_count);
    for (int i = 0; i < sprites_count; i++) {
        fseek(wadFile, directory[sprites_pointer+i].start, SEEK_SET);
        fread(&sprites[i], sizeof(Sprite), 1, wadFile);
    }
    
    sprite_images = malloc(sizeof(unsigned char*) * sprites_count);
    int column_pointers[320];

    for (int i = 0; i < sprites_count; i++) {
            
        //    for (int i = 0; i < 100; i++) {
        //        printf("Sprite %d is %dx%d\n", i, sprites[i].width, sprites[i].height);
        //    }
            
            TARGET_SPRITE = i;
            //printf("Sprite %.*s is %dx%d found at %d. left offset = %d, top_offset = %d\n", 8, directory[sprites_pointer+TARGET_SPRITE].name, sprites[TARGET_SPRITE].width, sprites[TARGET_SPRITE].height, directory[sprites_pointer+TARGET_SPRITE].start, sprites[TARGET_SPRITE].left_offset, sprites[TARGET_SPRITE].top_offset);

            unsigned char *rotated_sprite; // the original sprite, the way doom stores it
            
            // array of pointers decoded image data for all the sprites
            // allocate memory for this particular sprite
            sprite_images[TARGET_SPRITE] = calloc(1, sizeof(unsigned char) * sprites[TARGET_SPRITE].width * sprites[TARGET_SPRITE].height);
            rotated_sprite = calloc(1, sizeof(unsigned char) * sprites[TARGET_SPRITE].width * sprites[TARGET_SPRITE].height);
            
            // sprite data header
            // 4 16-bit ints, w, h, left_offset, top_offset
            // width # of long pointers to rows of data
            // each row (bytes): row to start drawing
            //                   pixel count
            //                   blank byte, picture data bytes, blank
            //                   FF ends column (also will signify empty row)
            //                   other wise draw more data for this column
            
            // go to the start of the sprite data
            // sprites_pointer is the first/starting sprite
            fseek(wadFile, directory[sprites_pointer+TARGET_SPRITE].start + 8, SEEK_SET);
            int32_t image_offset; // where we are drawing in the current sprite
            unsigned char b1, b2;
            int sprite_data_start = directory[sprites_pointer+TARGET_SPRITE].start;
            int line_start;
            fread(&column_pointers, sizeof(int32_t), sprites[TARGET_SPRITE].width, wadFile);
            //printf("Sprite data starts at: %d %x\n", sprite_data_start, sprite_data_start);
            
            for (int i = 0; i < sprites[TARGET_SPRITE].width; i++) {
                //printf("Sprite column %d data lives at %d %x\n", i, column_pointers[i], column_pointers[i]);
                // read the next column every iteration of the loop
                fseek(wadFile, sprite_data_start + column_pointers[i], SEEK_SET);
                // start writing pixels at the beginning of the line
                line_start = sprites[TARGET_SPRITE].height * i;
                image_offset = line_start;

                while (TRUE) {
                    fread(&b1, sizeof(unsigned char), 1, wadFile); // row to start drawing
                    if (b1 == 0xff) {
                        //printf("Breaking on column %d\n", i);
                        break; // this whole line is blank/transparent
                    } else {
                        image_offset = line_start + b1;
                        //printf("image_offset = %d\n", image_offset);
                        fread(&b2, sizeof(unsigned char), 1, wadFile); // count of data bytes
                        fseek(wadFile, 1, SEEK_CUR); // skip first byte
                        fread(&rotated_sprite[image_offset], sizeof(unsigned char) * b2, 1, wadFile);
                        image_offset += b2;
                        fseek(wadFile, 1, SEEK_CUR); // skip last byte
                        //printf("Drawing column %d, starting at row %d\n", i, b1);
                        //printf("Copying %d bytes\n", b2);
                        if (image_offset > sprites[TARGET_SPRITE].height * (i + 1)) {
                            printf("Image offset is off the grid: offset %d, eol: %d\n", image_offset, sprites[TARGET_SPRITE].height * (i + 1));
                        }
                    }
                    if (image_offset > sprites[TARGET_SPRITE].width * sprites[TARGET_SPRITE].height) {
                        printf("Something went wrong, image data is larger than sprite dimensions\n");
                        exit(1);
                    }
                }
            }
            // dump sprite to text
            //    for (int i = 0; i < sprites[0].height * sprites[0].width; i++) {
            //        printf("%x", sprite_images[0][i]);
            //    }

            // flip the sprite, because doom stores them rotated 90 degrees to the left
            for (int x = 0; x < sprites[TARGET_SPRITE].height; x++) {
                    for (int y = 0; y < sprites[TARGET_SPRITE].width; y++) {
                    sprite_images[TARGET_SPRITE][x + (y * sprites[TARGET_SPRITE].height)] =
                                  rotated_sprite[x + (y * sprites[TARGET_SPRITE].height)];
                }
            }
            // don't forget to swap height/width on the sprite data structure
            /*int swap = sprites[TARGET_SPRITE].height;
            sprites[TARGET_SPRITE].height = sprites[TARGET_SPRITE].width;
            sprites[TARGET_SPRITE].width = swap;
            */
        free(rotated_sprite);
    }

    printf("Closing .WAD file\n");
    fclose(wadFile);
    
    /* dump sidedefs
     
    for (int v = 0; v < sidedefs_count; v++) {
        printf("xoff: %d yoff: %d %.*s %.*s %.*s %d\n", sidedefs[v].xoff, sidedefs[v].yoff, 8, sidedefs[v].tex1, 8, sidedefs[v].tex2, 8, sidedefs[v].tex3, sidedefs[v].sector);
    }
    printf("\nWrote %d sidedefs\n", sidedefs_count);
    */
    
    /*
      How to access the first, and the last items in our directory
    
    printf("\n%.*s \n\n %d %d\n", 16, directory->name, directory->start, directory->size);
    printf("\n%.*s \n\n %d %d\n", 16, directory[1263].name, directory[1263].start, directory[1263].size);
     
    */
    
// dump WAD file directory
//    for (int i = 0; i < header.dirsize; i++) {
//        fread(&Entry, sizeof(Entry), 1, WADFile);
//        printf("%.*s %d %d\n", 8, Entry.name, Entry.size, Entry.start);
//    }

    NSLog(@"applicationDidFinishLaunching");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
