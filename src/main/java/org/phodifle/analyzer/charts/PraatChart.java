package org.phodifle.analyzer.charts;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Font;
import java.awt.GradientPaint;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import javax.imageio.ImageIO;

import org.phodifle.analyzer.model.Locutor;
import org.phodifle.analyzer.model.Sample;
import org.phodifle.analyzer.model.mean.SampleMean;


public class PraatChart {
	int scale, w, h, sc, factorF0;
	BufferedImage img;

	public PraatChart() {
		this(2, 2);
	}

	public PraatChart(int scale, int factorF0) {
		this.scale = scale;
		this.factorF0 = factorF0; //4
		w = 800*scale;
		h = 550*scale;
		sc = 600*scale;
		img = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);
	}

	public void generateChart() {
		generateChart(null);
	}

	public void generateChart(SampleMean mean) {
		String title = mean.getLabel().split(":")[0];
		String labelBottom = "Syllables";
		String labelRight = "Duration";
		String labelLeft = "F0";
		
		Graphics2D ig = img.createGraphics();
		
		// Set drawing attributes for the foreground.
	    // Most importantly, turn on anti-aliasing.
	    ig.setStroke(new BasicStroke(2.0f)); // 2-pixel lines
	    ig.setFont(new Font("Serif", Font.BOLD, 12*scale)); // 12-point font
	    ig.setRenderingHint(RenderingHints.KEY_ANTIALIASING, // Anti-alias
	        RenderingHints.VALUE_ANTIALIAS_ON);

	    int m100 = 100*scale;
	    int m50 = 50*scale;
	    int m400 = 400*scale;
		
		ig.setColor(Color.white);
		ig.fillRect(0, 0, w, h);
		ig.setColor(Color.black);
		ig.fillRect(m100-2*scale, m50-2*scale, sc+2*scale, m400+4*scale);
		ig.setColor(Color.white);
		ig.fillRect(m100, m50, sc-2*scale, m400);
		float totalDuration = mean.getTotalChildsMeanDuration()*100;
		int size = mean.getChilds().size();
		
		float factor = (sc+(size/2)*scale)/totalDuration;
		if (size==1) factor*=0.5;
		if (size==2) factor*=0.75;
		int x = m100;
		int minLeft = 0;
		int maxLeft = 0;
		int maxRight = 0;
		int index = 0;
		
		for (SampleMean child: mean.getChilds().values()) {
			int val = (int)(child.getMeanDuration()*100);
//		for (int val: xBars) {
			if (val>maxRight) maxRight=val;
			int dw = (int)(val*factor);
			int dh = (int)(val*factor);
			if (size==1) dw/=0.5;
			if (size==2) dw/=0.75;
			// DRAW CHART
			ig.setColor(Color.black);
			int dec = 0;
			if (scale>3) dec=scale;
//			if (index<size-1) dec = dec-2*scale;
			ig.fillRect(x+scale, h-dh-m100-scale, dw-3*scale-dec, dh);
			ig.setPaint(new GradientPaint(160F*scale, 120F*scale, Color.lightGray,260F*scale, 190F*scale, Color.gray, true));		
			ig.fillRect(x+2*scale, h-dh-m100, dw-5*scale-dec, dh-2*scale);
			
			// SUB CHARTS
			int ssize = child.getChilds().size();
			int sindex=0;
			int stotal = (int)(child.getTotalChildsMeanDuration()*100);
			int ssum = 0;
			int sh = dh-2*scale;
			for (SampleMean schild: child.getChilds().values()) {
				int dx = x+dw/2;
				String slabel = schild.getLabel().split(":")[1];
				int alpha = 255*sindex/ssize;
				ig.setColor(new Color(255, 255, 255, alpha));
				int smeand = (int)(schild.getMeanDuration()*100);
				int yp = h-dh-m100+ssum*sh/stotal;
				int hp = sh*smeand/stotal;
				ig.fillRect(x+2*scale, yp, dw-5*scale-dec, hp);
				ssum += smeand;

				ig.setFont(new Font("Arial", Font.BOLD, 12*scale));
				int lw = ig.getFontMetrics().stringWidth(slabel);
				int lh = ig.getFontMetrics().getHeight()/2;
				ig.setColor(Color.black);
				ig.drawString(slabel, dx-(lw/2), yp+(hp/2)+lh);
				
				sindex++;
			}
			// /DRAW SUB CHARTS
			
			// DRAW FREQUENCIES
			for (Locutor locutor: child.getEntities().getLocutors().values()) {
				float[] f0t = new float[3];
				for (int if0=0 ; if0<3 ; if0++) {
					f0t[if0] = child.getMeanF0(if0, locutor);
					int f0scale = (int)f0t[if0]*scale*4;
					if (f0scale<minLeft) minLeft = f0scale;
					if (f0scale>maxLeft) maxLeft = f0scale;
					
				}

				boolean ignored = false;
				for (float f0: f0t) {
					if (f0==Sample.UNDEFINED) ignored=true;
				}
				if (ignored) continue;
				int dwf = dw-3*scale-dec;
				int[] xPoints = new int[3]; 
				int[] yPoints = new int[3];
				xPoints[0] = x + 5*scale;
				xPoints[1] = x + dwf/2;
				xPoints[2] = x + dwf - 5*scale;
				yPoints[0] = 250*scale - (int)f0t[0]*scale*factorF0;
				yPoints[1] = 250*scale - (int)f0t[1]*scale*factorF0;
				yPoints[2] = 250*scale - (int)f0t[2]*scale*factorF0;
				ig.setColor(locutor.getColor());
				float dashes[] = { 10 };
				ig.setPaint( locutor.getColor() );                            
				ig.setStroke( new BasicStroke( 4, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND, 10, dashes, 0 ) );            
				ig.drawPolyline(xPoints, yPoints, 3);
				int iloc = new Integer(locutor.getName()).intValue();
				int wp = 2;
				drawPicto(ig, xPoints[0], yPoints[0], iloc, wp);
				drawPicto(ig, xPoints[1], yPoints[1], iloc, wp);
				drawPicto(ig, xPoints[2], yPoints[2], iloc, wp);
				
				
			}
			// DRAW FREQUENCIES
			
			
			// /DRAW CHARTS
			
			// BOTTOM INDICATORS
			ig.setColor(Color.black);
			int dx = x+dw/2;
			ig.drawLine(dx, h-m100+scale, dx, h-m100+4*scale);
			int lw = ig.getFontMetrics().stringWidth(child.getLabel());
			ig.drawString(child.getLabel(), dx-(lw/2), h-80*scale);
			// /BOTTOM INDICATORS
			
			index++;
			x+=dw;
		}
		
		// Clear top graph
		ig.setColor(Color.white);
		ig.fillRect(0, 0, w, m50-2*scale);
		ig.setColor(Color.black);
		
		// LOCUTORS LEGENDS
		int iloc= 0;
		
		Collection<Locutor> coll = mean.getChildLocutors().values();
		List<Locutor> locutors = new ArrayList<Locutor>(coll);
		Collections.sort(locutors, LOCUTOR_ORDER);
		
		for (Locutor locutor: locutors) {
			ig.setColor(locutor.getColor());
			String name = "L "+locutor.getName();
			int lw = ig.getFontMetrics().stringWidth(name);
			ig.setStroke( new BasicStroke( scale, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND) );            
			ig.drawString(name, 130*scale+50*scale*iloc, h- 15*scale);
			ig.drawRect(126*scale+50*scale*iloc, h- 30*scale, lw+8*scale, 20*scale);
			int il = new Integer(locutor.getName()).intValue();
			drawPicto(ig, 118*scale+50*scale*iloc, h-20*scale, il, 4);
			iloc++;
		}
		// /LOCUTORS LEGENDS
		
	    ig.setStroke(new BasicStroke(scale)); // 2-pixel lines

		// LEFT INDICATORS
		ig.setColor(Color.black);
//	    System.out.println("MIN:"+minLeft+"  MAX:"+maxLeft);
	    for (int ym = 0 ; ym<5 ; ) {
	    	ig.drawLine(m100-2*scale, 250*scale-ym*200, m100-4*scale, 250*scale-ym*200);
	    	String lab = ""+ym*20;
	    	int wstr = ig.getFontMetrics().stringWidth(lab);
	    	ig.drawString(lab, m100-8*scale-wstr, 250*scale-ym*200+4*scale);
	    	if (ym*200>maxLeft) ym=5;
	    	ym++;
	    }
	    for (int ym = 1 ; ym<5 ; ) {
	    	ig.drawLine(m100-2*scale, 250*scale+ym*200, m100-4*scale, 250*scale+ym*200);
	    	String lab = "-"+ym*20;
	    	int wstr = ig.getFontMetrics().stringWidth(lab);
	    	ig.drawString(lab, m100-8*scale-wstr, 250*scale+ym*200+4*scale);
	    	if (-ym*200<minLeft) ym=5;
	    	ym++;
	    }
	    
		// /LEFT INDICATORS
		
		// RIGHT INDICATORS
		ig.setColor(Color.black);
		int dm = h- (int)(maxRight*factor) - m100 - scale;
		int dm0 = h - m100;
		int ecart = (dm-dm0)/4;
		for (int i=0 ; i<5 ; i++) {
			ig.drawLine(sc+m100, dm0+i*ecart, sc+m100+2*scale, dm0+i*ecart);
			int val = maxRight/4*i;
			
			ig.drawString(""+val, sc+m100+7*scale, dm0+i*ecart+4*scale);
		}
		// /RIGHT INDICATORS
		
		//LABELS
		ig.setFont(new Font("Serif", Font.BOLD, 16*scale));
		int tw = ig.getFontMetrics().stringWidth(title);
		ig.drawString(title, w/2-tw/2, 30*scale);
		
		ig.setFont(new Font("Serif", Font.BOLD, 14*scale));
		int lw = ig.getFontMetrics().stringWidth(labelBottom);
		ig.drawString(labelBottom, w/2-lw/2, h-55*scale);
		
		Font font = ig.getFont();
		AffineTransform fontAT = new AffineTransform();
		fontAT.rotate(Math.PI/2);
		Font rFont = font.deriveFont(fontAT);
		ig.setFont(rFont);
		ig.drawString(labelRight, w-m50, (h/2)-50*scale);

		fontAT.rotate(Math.PI);
		rFont = font.deriveFont(fontAT);
		ig.setFont(rFont);
		ig.drawString(labelLeft, 60*scale, (h/2)-20*scale);

		ig.setFont(font);
		
		// /LABELS

	}
	
	public void exportPNGImage(String filename) {
		File thumbnailFile = new File(filename);
		try {
			ImageIO.write(img, "png", thumbnailFile);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	private void drawPicto(Graphics2D ig, int x, int y, int type, int width) {
		ig.setStroke( new BasicStroke( 2*width, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND) );            
		int step = width*scale;
		int size = 2*step;
//		Color ctemp = ig.getColor();
//		ig.setColor(Color.white);
//		ig.fillRect(x-step, y-step, size, size);
//		ig.setColor(ctemp);
		switch (type) {
		case 1:
			ig.fillArc(x-step, y-step, size, size, 0, 360);
			break;
		case 2:
			ig.fillRect(x-step, y-step, size, size);
			break;
		case 3:
			ig.fillPolygon(new int[]{x-step, x, x+step, x}, new int[]{y, y-step, y, y+step}, 4);
			break;
		case 4:
			ig.fillPolygon(new int[]{x-step, x, x+step}, new int[]{y+step, y-step, y+step}, 3);
			break;
		case 5:
			ig.drawLine(x, y-step, x, y+step);
			ig.drawLine(x-step, y, x+step, y);
			break;
		case 6:
			ig.drawLine(x-step, y-step, x+step, y+step);
			ig.drawLine(x-step, y+step, x+step, y-step);
			break;
		case 7:
			ig.drawArc(x-step, y-step, size, size, 0, 360);
			break;
		case 8:
			ig.drawRect(x-step, y-step, size, size);
			break;
		case 9:
			ig.drawPolygon(new int[]{x-step, x, x+step, x}, new int[]{y, y-step, y, y+step}, 4);
			break;
		case 10:
			ig.drawPolygon(new int[]{x-step, x, x+step}, new int[]{y+step, y-step, y+step}, 3);
			break;
		default:
			ig.fillArc(x-step/2, y-step/2, size/2, size/2, 0, 360);
		}
	}
	
//	private int getTotal(int[] values) {
//		int total = 0;
//		for (int val: values) {
//			total+=val;
//		}
//		return total;
//	}
	
	static final Comparator<Locutor> LOCUTOR_ORDER =
        new Comparator<Locutor>() {
			public int compare(Locutor l1, Locutor l2) {
				try {
					Integer i1 = new Integer(l1.getName());
					Integer i2 = new Integer(l2.getName());
					return i1.compareTo(i2);
				} catch (NumberFormatException e) {
					e.printStackTrace();
				}
				
				return l1.getName().compareTo(l2.getName());
			}
	};



}
