/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rsmartcn;

import java.io.StringReader;
import java.io.IOException;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.util.Version;
import org.apache.lucene.analysis.cn.smart.SmartChineseAnalyzer;
import org.apache.lucene.analysis.tokenattributes.CharTermAttribute;
/**
 *
 * @author rghuang
 */
public class rsmartcn {
 
   public String Seg(String text, boolean useStopWords) throws IOException{
       Analyzer sca = new SmartChineseAnalyzer(Version.LUCENE_34, useStopWords);
       String ans = "";
       StringReader reader = new StringReader(text);
       TokenStream ts = sca.tokenStream(text, reader); 
       boolean first = true;
       while (ts.incrementToken()) {
           if (!first) {
                ans = ans + " ";
            }
           CharTermAttribute ta = ts.getAttribute(CharTermAttribute.class);
           ans = ans + ta.toString();
           first = false;
       }
       ts.close();
       return ans;
   }
}