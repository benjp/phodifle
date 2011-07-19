package org.phodifle.analyzer.model;


public class Sample {
	private String label;
	private boolean isNormalized;
	/* 
	 * REAL
	 */
	private float start;
	private float duration;
	private float durationp1;
	private float durationp2;
	private float[] F0;
	
	/* 
	 * NORMALIZED
	 */
	private float normDuration;
	private float[] normF0;
	
	public final static float UNDEFINED = -65000;
	
	public Sample (String label) {
		this.label = label;
//		this.subSamples = new TreeMap<Float, Sample>();
		this.isNormalized = false;
		F0 = new float[]{UNDEFINED, UNDEFINED, UNDEFINED};
		normF0 = new float[]{UNDEFINED, UNDEFINED, UNDEFINED};
	}
	
	
	
//	public void addSampleIfInside(Sample sample) {
//		float start = this.start;
//		float substart = sample.getStart();
//		float end = start+duration/1000+0.001f;
//		float subend = sample.getStart()+sample.getDuration()/1000;
//		boolean inside = (substart>=start && subend<=end);
//		if (inside) {
//			System.out.println(sample.getLabel() + "==>" + label + " : "+inside);
//			subSamples.put(sample.getStart(), sample);
//			sample.setParent(this);
//		}
//	}
//	
//	public Collection<Sample> getSubSample() {
//		return subSamples.values();
//	}
	
	public void setDurations(float duration, float durationp1, float durationp2) {
		this.duration = duration;
		this.durationp1 = durationp1;
		this.durationp2 = durationp2;
	}
	
	public String getLabel() {
		return label;
	}
	public void setLabel(String label) {
		this.label = label;
	}
	public float getDuration() {
		return duration;
	}
	public void setDuration(float duration) {
		this.duration = duration;
	}
	public float getDurationp1() {
		return durationp1;
	}
	public void setDurationp1(float durationp1) {
		this.durationp1 = durationp1;
	}
	public float getDurationp2() {
		return durationp2;
	}
	public void setDurationp2(float durationp2) {
		this.durationp2 = durationp2;
	}
	
	
	public float getNormDuration() {
		return normDuration;
	}

	public void setNormDuration(float normDuration) {
		this.normDuration = normDuration;
		this.isNormalized = true;
	}
	
	public boolean isNormalized() {
		return isNormalized;
	}

	public float getStart() {
		return start*1000;
	}

	public float getEnd() {
		return start*1000+duration;
	}
	
	public void setStart(float start) {
		this.start = start;
	}


	public float[] getF0() {
		return F0;
	}



	public void setF0Beg(float f0) {
		F0[0] = f0;
	}
	public void setF0Mid(float f0) {
		F0[1] = f0;
	}
	public void setF0End(float f0) {
		F0[2] = f0;
	}



	public float[] getNormF0() {
		return normF0;
	}



	public void setNormF0(float normF0, int index) {
		this.normF0[index] = normF0;
	}


	public static final float computeFloatValue(String s) {
		float f;
		try {
			f = new Float(s.trim()).floatValue();
		} catch (NumberFormatException e) {
			f = Sample.UNDEFINED;
		}
		return f;
		
	}
	
	public String toXML() {
		StringBuffer sb = new StringBuffer();
		sb.append("<sample label=\""+label+"\">");
		sb.append("\n\t<start>"+start+"</start>");
		sb.append("\n\t<duration>"+duration+"</duration>");
		sb.append("\n\t<norm-duration>"+normDuration+"</norm-duration>");
//		sb.append("\n\t<durationp1>"+durationp1+"</durationp1>");
//		sb.append("\n\t<durationp2>"+durationp2+"</durationp2>");
		sb.append("\n\t<f0 beg=\""+F0[0]+"\" mid=\""+F0[1]+"\" end=\""+F0[2]+"\" />");
		sb.append("\n\t<normf0 beg=\""+normF0[0]+"\" mid=\""+normF0[1]+"\" end=\""+normF0[2]+"\" />");

//		for (Sample sample : subSamples.values()) {
//			sb.append("\n\t");
//			sb.append(sample.toXML());
//		}

		sb.append("</sample>\n");
		return sb.toString();
	}
	
}
