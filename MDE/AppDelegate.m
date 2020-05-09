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

SEG *segs;
SSector *ssectors;
Node *nodes;
Sector *sectors;

int things_count, linedefs_count, sidedefs_count, vertexes_count;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    FILE *wadFile;
    WADFileHeader header;
    WADFileDirectoryEntry *directory;
    
    wadFile = fopen("/Users/robert/Downloads/Doom/Proj/DOOM1.WAD", "r");
    
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
    
    for (int i = 0; i < header.dirsize; i++) {
        if (!strncmp("E1M5", directory[i].name, 4)) {
            // printf("\nFound it! Entry #%d %d %d\n", i, directory[i].start, directory[i].size);
            // fread(<#void *restrict __ptr#>, <#size_t __size#>, <#size_t __nitems#>, FILE *restrict __stream)
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
            vertexes_count = directory[i+3].size / sizeof(Vertex);
            fread(vertexes, sizeof(Vertex), directory[i+4].size / sizeof(Vertex), wadFile);
        }
        //printf("%.*s ", 8, directory[i].name);
    }

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
