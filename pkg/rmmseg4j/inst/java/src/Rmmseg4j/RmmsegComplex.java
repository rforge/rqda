/*
Rewritten by ronggui huang on 18 Sep. 2011
 * revised on 16 June 2012
Based on the Complex example
 */
package Rmmseg4j;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.StringReader;
import com.chenlb.mmseg4j.ComplexSeg;
import com.chenlb.mmseg4j.Dictionary;
import com.chenlb.mmseg4j.MMSeg;
import com.chenlb.mmseg4j.Seg;
import com.chenlb.mmseg4j.Word;

public class RmmsegComplex {

   public Dictionary dic = Dictionary.getInstance();
   /*must be public for R to access it*/
   
   protected Seg getSeg(Dictionary dic) {
        return new ComplexSeg(dic);
   }

    protected String segWords(Reader input, String wordSpilt) throws IOException {
        StringBuilder sb = new StringBuilder();
        Seg seg = getSeg(dic);	//取得不同的分词具体算法
        MMSeg mmSeg = new MMSeg(input, seg);
        Word word = null;
        boolean first = true;
        while ((word = mmSeg.next()) != null) {
            if (!first) {
                sb.append(wordSpilt);
            }
            String w = word.getString();
            sb.append(w);
            first = false;
        }
        return sb.toString();
    }

    public String segWords(String txt, String wordSpilt) throws IOException {
        return segWords(new StringReader(txt), wordSpilt);
    }

}