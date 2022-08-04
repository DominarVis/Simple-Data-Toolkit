/*
    Copyright (C) 2022 Vis LLC - All Rights Reserved

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

/*
    Simple Data Toolkit
    Standard/Core Library - Source code can be found on SourceForge.net
*/

package com.sdtk.std;

@:expose
@:nativeGen
class Calc {
    public static function average(reader : DataIterable<Float>) : Float {
        var total : Float = 0;
        var count : Int = 0;
        var readerI : Iterator<Float> = reader.iterator();
        while (readerI.hasNext()) {
            total += cast readerI.next();
            count++;
        }
        return total/count;
    }

    public static function standardDeviation(reader : DataIterable<Float>, ?avg : Float = null) : Float {
        if (avg == null) {
            avg = average(reader);
        }
        var total : Float = 0;
        var count : Int = 0;
        var reader2 : DataIterator<Float> = reader.iterator();
        while (reader2.hasNext()) {
            var value : Float = reader2.next();
            total += (value - avg) * (value - avg);
            count++;
        }
        return Math.sqrt(total/count);
    }

    public static function correlation(readerI : DataIterable<Float>, readerJ : DataIterable<Float>, ?avgI : Float = null, ?avgJ : Float = null, ?sdI : Float = null, ?sdJ : Float = null) : Float {
        if (avgI == null) {
            avgI = average(readerI);
        }
        if (avgJ == null) {
            avgJ = average(readerJ);
        }
        if (sdI == null) {
            sdI = standardDeviation(readerI, avgI);
        }
        if (sdJ == null) {
            sdJ = standardDeviation(readerJ, avgJ);
        }
        var count : Int = 0;
        var total : Float = 0;
        var readerI2 : DataIterator<Float> = readerI.iterator();
        var readerJ2 : DataIterator<Float> = readerJ.iterator();
        while (readerI2.hasNext()) {
            var i : Float = readerI2.next();
            var j : Float = readerJ2.next();
            total += i * j;
            count++;
        }
        return (total - count * avgI * avgJ) / ((count - 1) * sdI * sdJ);
    }

    // j = slope * i + intercept
    public static function regressionSlope(readerI : DataIterable<Float>, readerJ : DataIterable<Float>, ?avgI : Float = null, ?avgJ : Float = null, ?sdI : Float = null, ?sdJ : Float = null, ?correlationIJ : Float = null) : Float {
        if (avgI == null && (correlationIJ == null || sdI == null)) {
            avgI = average(readerI);
        }
        if (avgJ == null && (correlationIJ == null || sdJ == null)) {
            avgJ = average(readerJ);
        }
        if (sdI == null) {
            sdI = standardDeviation(readerI, avgI);
        }
        if (sdJ == null) {
            sdJ = standardDeviation(readerJ, avgJ);
        }
        if (correlationIJ == null) {
            correlationIJ = correlation(readerI, readerJ, avgI, avgJ, sdI, sdJ);
        }
        return correlationIJ * sdJ / sdI;
    }

    // j = slope * i + intercept
    public static function regressionIntercept(readerI : DataIterable<Float>, readerJ : DataIterable<Float>, ?avgI : Float = null, ?avgJ : Float = null, ?sdI : Float = null, ?sdJ : Float = null, ?correlationIJ : Float = null, ?slope : Float = null) : Float {
        if (avgI == null) {
            avgI = average(readerI);
        }
        if (avgJ == null) {
            avgJ = average(readerJ);
        }
        if (slope == null) {
            slope = regressionSlope(readerI, readerJ, avgI, avgJ, sdI, sdJ, correlationIJ);
        }

        return avgJ - slope * avgI;
    }
}