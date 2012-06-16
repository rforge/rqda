package Rmmseg4j;

import java.io.IOException;
import com.chenlb.mmseg4j.Dictionary;
import com.chenlb.mmseg4j.MaxWordSeg;
import com.chenlb.mmseg4j.Seg;

public class RmmsegMaxWord extends RmmsegComplex {

	protected Seg getSeg(Dictionary dic) {
		return new MaxWordSeg(dic);
	}

}
