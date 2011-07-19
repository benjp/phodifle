package org.phodifle.analyzer.util;

import java.util.Collection;
import java.util.List;

import org.phodifle.analyzer.model.Sample;

import com.ibm.icu.text.Transliterator;

public final class Util {

	public static Sample getContainer (Sample sample, Collection<Sample> samples) {
		float start = sample.getStart();
		float end = start + sample.getDuration();
		for (Sample container: samples) {
			float cstart = container.getStart();
			float cend = cstart + container.getDuration() + 0.001f;
			if (start>=cstart && end<=cend) {
				return container;
			}
		}
		return null;
	}

	public static Sample getFirstChild (Sample sample, Collection<Sample> samples) {
		float start = sample.getStart();
		float end = start + sample.getDuration();
		for (Sample child: samples) {
			float cstart = child.getStart();
			float cend = cstart + child.getDuration();
			if (cstart>=start && cend<=end) {
				return child;
			}
		}
		return null;
	}

	public static float getMean(List<Float> values) {
		float mean = 0;
		int i = values.size();
		float total = 0;
		for (float val: values) {
			total+=val;
		}
		mean = total/i;
		return mean;
	}

	public static float getStandardDeviation(List<Float> values) {
		double dev = 0;
		int i = values.size();
		float M = Util.getMean(values);
		double sd2 = 0;
		for (float val: values) {
			float d = val - M;
			/**
			 * TODO : Test with : sd2 += Math.pow(d, 2);
			 */
			sd2 = Math.pow(d, 2);
		}
		dev = Math.sqrt(sd2/i);


		return new Float(dev).floatValue();
	}

	public static float getStandardizeValue(float X, float M, float dev) {
		float sv = (X-M)/dev ;
		return sv;
	}

	public static float getStandardizeValue(float X, float M) {
		return ( X/M );
	}

	public static String cleanString(String str) {

		Transliterator accentsconverter = Transliterator.getInstance("Latin; NFD; [:Nonspacing Mark:] Remove; NFC;");

		str = accentsconverter.transliterate(str); 

		//the character ? seems to not be changed to d by the transliterate function 

		StringBuffer cleanedStr = new StringBuffer(str.trim());
		// delete special character
		for(int i = 0; i < cleanedStr.length(); i++) {
			char c = cleanedStr.charAt(i);
			if(c == ' ') {
				if (i > 0 && cleanedStr.charAt(i - 1) == '-') {
					cleanedStr.deleteCharAt(i--);
				}
				else {
					c = '-';
					cleanedStr.setCharAt(i, c);
				}
				continue;
			}

			if(!(Character.isLetterOrDigit(c) || c == '-')) {
				cleanedStr.deleteCharAt(i--);
				continue;
			}

			if(i > 0 && c == '-' && cleanedStr.charAt(i-1) == '-')
				cleanedStr.deleteCharAt(i--);
		}
		return cleanedStr.toString().toLowerCase();
	}


}
