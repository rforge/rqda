/**
 * R interface to smartcn
 * by Ronggui HUANG
 **/

package rsmartcn;
import java.io.Reader;
import java.io.StringReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.Token;
import org.apache.lucene.util.Version; 
import org.apache.lucene.analysis.cn.smart.SmartChineseAnalyzer;
import org.apache.lucene.analysis.tokenattributes.TermAttribute; 

public class rsmartcn
{
    public static void main(String args[]) throws IOException {
	String text = new String();
	if (args.length == 0) {
	    System.out.println("Usage:\n rsmartcn text.");
	} else {
	    if (args.length > 0 ) {
		text = new String (args[0]);
	    }
	    String ans = new String();
	    ans = new rsmartcn().textMethod(text);
	    System.out.println(ans);
	}
    }
    
    private String textMethod(String text) throws UnsupportedEncodingException,
	FileNotFoundException, IOException {
        Token newToken = new Token();
        Analyzer chineseAnalyzer = new SmartChineseAnalyzer(Version.LUCENE_CURRENT);
        /** append , false if not load stopwords **/
	Reader sentence = new StringReader(text);
        TokenStream newTokenstream = chineseAnalyzer.tokenStream("", sentence);
	/** should use "sentence" instead of ""?
         * both seem to work fine
         **/
        String  ans = new String();
	TermAttribute termAttribute = newTokenstream.getAttribute(TermAttribute.class);  
	while (newTokenstream.incrementToken()) {  
	    ans = ans + termAttribute.term() + " ";
	}
        newTokenstream.close();
        return ans;
    }
}
