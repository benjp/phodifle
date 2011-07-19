/**
 * 
 */
package org.phodifle.analyzer;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Writer;

import org.phodifle.analyzer.model.Analyze;
import org.phodifle.analyzer.model.Locutor;
import org.phodifle.analyzer.model.Sample;
import org.phodifle.analyzer.model.Tier;

/**
 * @author benjamin
 *
 */
public class Analyzer {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		if (args.length>0) {
			String file = args[0];
			int scale = new Integer(args[1]);
			int factorF0 = new Integer(args[2]);
			System.out.println("file="+file);
			Analyze analyze = new Analyze();
			try{
				// Open the file that is the first 
				// command line parameter
				FileInputStream fstream = new FileInputStream(file);
				// Get the object of DataInputStream
				DataInputStream in = new DataInputStream(fstream);
				BufferedReader br = new BufferedReader(new InputStreamReader(in));
				String strLine;
				while ((strLine = br.readLine()) != null)   {
					String[] split = strLine.split("\t");
					String loc = new String(split[1].trim());
					if (split.length>4 && !loc.matches("File")) {
						Locutor locutor = analyze.getLocutor(loc);
						String ti = split[2].trim();
						Tier tier = locutor.getTier(ti);
						String sLabel = split[3].trim();
						float sStart = Sample.computeFloatValue(split[4]);
						float sDur = Sample.computeFloatValue(split[5]);
						float sDurP1 = Sample.computeFloatValue(split[6]);
						float sDurP2 = Sample.computeFloatValue(split[7]);
						float sF0Beg = Sample.computeFloatValue(split[12]);
						float sF0Mid = Sample.computeFloatValue(split[13]);
						float sF0End = Sample.computeFloatValue(split[14]);
						
						Sample sample = new Sample(sLabel);
						sample.setDurations(sDur, sDurP1, sDurP2);
						sample.setStart(sStart);
						sample.setF0Beg(sF0Beg);
						sample.setF0Mid(sF0Mid);
						sample.setF0End(sF0End);
						tier.addSample(sample);
					}
				}
				//Close the input stream
				in.close();
			}catch (Exception e){//Catch exception if any
				System.err.println("Error: " + e.getMessage());
				e.printStackTrace();
			}
			
			analyze.compute();
			
//			System.out.println(analyze.toXML());
			
			Writer output=null;
			try {
				//use buffering
				output = new BufferedWriter(new FileWriter("/tmp/out.xml"));
				//FileWriter always assumes default encoding is OK!
//				output.write(analyze.meansToXML());
				output.write(analyze.printMeanTotal());
		    } catch (Exception e) {
		    	e.printStackTrace();
			} finally {
		      if (output!=null)
				try {
					output.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
		    }
			
			analyze.generatePNG(scale, factorF0);

			System.out.println("<<< END");

			
		}

	}

}
