/*
 * For R interface to paoding chinese word segmentation system
 * Paoding is checked out from google code, svn 154
 * by Ronggui HUANG 20120624
 */
package rpaoding;

import net.paoding.analysis.analyzer.PaodingAnalyzer;

import java.io.StringReader;
import java.io.IOException;
import org.apache.commons.logging.LogFactory;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.Token;
import org.apache.lucene.analysis.TokenStream;
import net.paoding.analysis.analyzer.PaodingAnalyzer;
import org.apache.lucene.analysis.tokenattributes.TermAttribute;


/**
 * @author rghuang
 */
public class rpaoding {
   
    public String Seg(String text) throws IOException{
       Analyzer sca = new PaodingAnalyzer(); 
       String ans = "";
       StringReader reader = new StringReader(text);
       TokenStream stream = sca.tokenStream(text, reader); 
       stream.reset();
       boolean first = true;
       while (stream.incrementToken()) {
           if (!first) {
                ans = ans + " ";
            }
           TermAttribute termAtt = (TermAttribute) stream.addAttribute(TermAttribute.class); 
           ans = ans + termAtt.term();
           first = false;
       }
       return ans;
   }
    
}
    