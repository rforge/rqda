package Rmmseg4j;

import java.io.IOException;
import com.chenlb.mmseg4j.Dictionary;
import com.chenlb.mmseg4j.SimpleSeg;
import com.chenlb.mmseg4j.Seg;

public class RmmsegSimple extends RmmsegComplex {

	protected Seg getSeg(Dictionary dic) {
		return new SimpleSeg(dic);
	}

}
