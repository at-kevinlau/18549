/*
 * Create a new instance with:
 * ComponentFinder finder = new ComponentFinder(this, image);
 * where "image" is the PImage (or PGraphics) to be traced.
 * use the find()-function, to get all the contours in the contours arraylist.
 * Each contour is by itself an ArrayList of PVectors.
 *
 * render_blobs() will return a PImage object that is a rendering of all the
 * blobs in the traced image.
 *
 * The Image to be traced need to be black (0x000000) objects on white background.
 * So use the threshold-filter to get to that.
 *
 * Also, unless the outer border of pixles is white, the finder will hang.
 */

import java.util.ArrayList;
 
class ComponentFinder
{
    PApplet parent;
    public ArrayList contours;
    int[] inout;
    int[] L;
    PImage I;
    int C;
 
    // An array with the 8 direction coordinates (x1, y1, x2, y2... x8, y8)
    int cd[] = {1, 0, 1, 1, 0, 1, -1, 1, -1, 0, -1, -1, 0, -1, 1, -1 };
 
    public ComponentFinder(PApplet p, PImage img)
    {
    parent = p;
    I = img;
    C = 1;
    L = new int[I.width*I.height];
 
    }
 
    int getNumContours()
    {
    if(contours != null)
        return contours.size();
    else return 0;
    }
 
    public int find()
    {
        // Initialize the blob map to zero.
        for(int i = 0; i < I.width*I.height; i++)
        {
            L[i] = 0;
        }
 
        // Make a new array list to store each contour.
        contours = new ArrayList();
 
        C = 1;
         
        int pos = I.width; // Start analyzing the image at the second line
 
        I.loadPixels();
 
        // Label the first line as blank pixels.
        for(int x = 0; x < I.width; x++)
            L[x] = -1;
 
        for(int y = 1; y < I.height; y++)
        {
            for(int x = 0; x < I.width; x++)
            {
            if(L[pos] == 0) // Only process unlabeled pixels
            {
                if(((I.pixels[pos]&0xffffff) != 0x000000))
                {
                // White pixel
                L[pos] = -1;
                }
                else if(((I.pixels[pos]&0xffffff) == 0x000000))
                {
                if((I.pixels[pos-I.width]&0xffffff) != 0x000000)
                {
                    // If the pixel above is a white pixel,
                    // then this is the start of an outer contour
                    L[pos] = C;
                    // Start tracing an outer contour
                    contours.add(contourTrace(new PVector(x, y), 0, C));
                    C++;
                }
                if(((I.pixels[pos+I.width]&0xffffff) != 0x000000) && (L[pos+I.width] == 0))
                {
                    // If the pixel below is a white pixel, then it is the start of an
                    // inner contour, and we get the id for the outer contour
                    // then start tracing the inner contour
                    int l;
                    if(L[pos] != 0 ) l = L[pos];
                    else l  = L[pos-1];
                     
                    if(L[pos] != 0) L[pos] = l;
                        contours.add(contourTrace(new PVector(x, y), 1, l));
                }
                if(L[pos] == 0) if(L[pos-1] > 0) L[pos] = L[pos-1];
                }
            }
            pos++;
        }
    }
    I.updatePixels();
    return getNumContours();
    }
 
    // Traces a countour at the given pixel S,
    // r is set to 0 for outer contours, and 1 for inner contours.
    // c is the label to give the contour
    ArrayList contourTrace(PVector S, int r, int c)
    {
    int next = 8;
    ArrayList cont = new ArrayList(32);
    PVector current = new PVector();
    cont.add(S.get());
    if(r == 0) // Outer contour
        next = Trace((PVector)cont.get(cont.size()-1), 7, c);
    else if(r == 1) // Inner contour
        next = Trace((PVector)cont.get(cont.size()-1), 3, c);
 
    if(next == 8) return cont; // The pixel is isolated.
 
    PVector T = new PVector(S.x + cd[next<<1], S.y + cd[(next<<1)+1]);
    cont.add(T.get());
 
    next = Trace((PVector)cont.get(cont.size()-1), (next+6)%8, c);
 
    if(next == 8) return cont;
 
    while(true)
    {
 
        current.x = (float)((PVector)cont.get(cont.size()-1)).x + cd[(next<<1)%16];
         current.y = (float)((PVector)cont.get(cont.size()-1)).y + cd[((next<<1)+1)%16];
        next = Trace(current, (next+6)%8, c);
 
        // Check if we are back at start position
        if((current.x == S.x) && (current.y == S.y) && (current.x + cd[next<<1] == T.x) && (current.y + cd[(next<<1)+1] == T.y))
        {
        return cont;
        }
        else
        {
        cont.add(current.get());
        }
    }
    }
 
    int Trace(PVector P, int n, int c)
    {
        for(int i = 0; i < 8; i++)
        {
            // if pixel at position n+i is black, return n+i
            PVector ni = new PVector(P.x+cd[((i+n)%8)*2],
                        P.y+cd[((i+n)%8)*2+1]);
 
 
            if((I.pixels[(int)(ni.y)*I.width+(int)(ni.x)]&0xffffff) == 0x000000)
            {
 
                L[(int)(ni.y)*I.width+(int)(ni.x)] = c;
                return (i+n) % 8;
            }
            // if not, mark with a negative number
            else
            {
                if(L[(int)(ni.y)*I.width+(int)(ni.x)] == 0)
                    L[(int)(ni.y)*I.width+(int)(ni.x)] = -1;
            }
        }
        return 8; // Should only happen for isolated pixels.
    }
 
    public PImage render_blobs()
    {
        PImage blobs = parent.createImage(I.width, I.height, PApplet.RGB);
        blobs.loadPixels();
        parent.colorMode(PApplet.HSB);
        for(int i = 0; i < L.length; i++)
        {
            if (L[i] > 0)
                //|0xff000000;
                blobs.pixels[i] = color(PApplet.map(L[i], 1, C, 0, 255), 255, 255);
            if (L[i] == -1)
                blobs.pixels[i] = color(0, 0, 255);
            if (L[i] == -2)
                blobs.pixels[i] = color(0, 0, 0);
            if (L[i] == 0)
                blobs.pixels[i] = color(0, 0, 128);
        }
        blobs.updatePixels();
        return blobs;
    }
}

/*
 * An implementation of
 *  A linear-time component labeling algorithm using contour tracing technique 
 * by Fu Chang, Chun-Jen Chen, and Chi-Jen Lu
 *
 * Written in Java for use with the Processing (www.processing.org) library.
 *
 * Code written by Greger Stolt Nilsen
 * (gregersn@gmail.com / http://gregerstoltnilsen.net)
 * Copyright 2010, Greger Stolt Nilsen
 *
 * Code is provided  as is , and no warrenty is given. Use at your own risk.
 *
 * This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
 
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
 
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 */
