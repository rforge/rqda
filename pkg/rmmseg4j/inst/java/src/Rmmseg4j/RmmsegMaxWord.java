package Rmmseg4j;

import java.io.IOException;
import com.chenlb.mmseg4j.MaxWordSeg;
import com.chenlb.mmseg4j.Seg;

public class RmmsegMaxWord extends RmmsegComplex {

	protected Seg getSeg() {
		return new MaxWordSeg(dic);
	}

        private String textMethod(String txt) throws IOException {
            String res = "";
            res = new RmmsegMaxWord().run(txt);
            return res;
    }

}
