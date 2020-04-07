import java.util.ArrayList;
import java.awt.Rectangle;
import javax.swing.JPanel;
import java.awt.Image;
import java.awt.Graphics;
import java.awt.Graphics2D;

public class Barrier extends JPanel{
	
	/**
	 * ����ʵ��3���ϰ��������
	 * 0Ϊ�յ�;1Ϊ��Χ�߽�;2��3Ϊ�����ϰ���;�������ϰ����������Bomb��������
	 * 4Ϊ����;7Ϊ��ը��Ч��;�����߽��ں���Enemy��Bomb��������ϸ����
	 */
	private static final long serialVersionUID = 8258437213281553250L; // �Ҳ�֪������Ǹ���ģ���ֻ�Ǹ���java����ʾ�����������
	public static int place[][]=new int[20][20]; // ���������������񳡵�
	
	static{
		for(int i=0;i<20;i++){ // ��ѭ��ʵ�ֶ�ά��������������ķ��࣬����Ϊ���࣬���������������ϰ���
			for(int j=0;j<20;j++){
				if(i==0||i==19|j==0|j==19){
					Barrier.place[i][j]=1; // ����Χ�߽���Ϊ1
					continue;
				}
				int setBarrier=(int)(4*Math.random()); // �����������ʵ����һ��4���ϰ�����������
				if(setBarrier==1){
					Barrier.place[i][j]=0; // �������Ϊ1��Ҳ����Ϊ0����Ϊ�յ�
					continue;
				}
				Barrier.place[i][j]=setBarrier; // �����Ϊ2��3�����ɶ�Ӧ���ϰ���
			}
		}
		
		// ��ɫ���������벻��������ͬ����֤��ʼ�ļ����ط����붼�ǿյ�:
		Barrier.place[1][1]=0;
		Barrier.place[1][2]=0;
		Barrier.place[2][1]=0;
		
		// ���ɵ���:
		for(int i=0;i<WinOrLose.num_enemy;i++){ // ��ѭ��ʵ�ֵ��˳����ص�ѡ��
			int x=(int)(2+Math.random()*17); // ��֤���˲����ڱ߽������ɣ��Ҳ���һ��ʼ�Ͱ����Ǹ�ɱ��
			int y=(int)(2+Math.random()*17);
			Barrier.place[x][y]=4; // ��������Ϊ4
			// ��֤���˿��������ƶ�:
			if(Barrier.place[x+1][y]!=1) { // ���ǰ����Ϊ��Χ�߽磬����Ϊ�յ�
				Barrier.place[x+1][y]=0;
			}
			if(Barrier.place[x-1][y]!=1) {
				Barrier.place[x-1][y]=0;
			}
			if(Barrier.place[x][y+1]!=1) {
				Barrier.place[x][y+1]=0;
			}
			if(Barrier.place[x][y-1]!=1) {
				Barrier.place[x][y-1]=0;
			}
		}
	}
	
	// �����ϰ���:
	// �ο���https://www.jianshu.com/p/7cacc73c96c0. ����. ���. Particle system_useArrayList & Rectangle. 2015.11.13 22:33.

	private ArrayList<Rectangle> BarrierRect;
	private ArrayList<Rectangle> firework;
	public ArrayList<Rectangle> getBarrier() {
		return BarrierRect;
	}
	public ArrayList<Rectangle> getfirework() {
		return firework;
	}
	public Barrier(){
		BarrierRect=new ArrayList<Rectangle>();
		firework=new ArrayList<Rectangle>();
		for(int i=0;i<20;i++){ // ��ѭ��ʵ�������ϰ���1��2��3������
			for(int j=0;j<20;j++){
				if(Barrier.place[i][j]==1||Barrier.place[i][j]==2||Barrier.place[i][j]==3){
					BarrierRect.add(new Rectangle(j*30, i*30, 30, 30));
				} // �������Χ�߽�����ϰ���2��3���������ϰ������
				if(Barrier.place[i][j]==7){ // ��Ϊը����ը��Ļ�Ч������Bomb���л�����ϸ��������Ϊ7
					firework.add(new Rectangle(j*30, i*30, 30, 30));
				}
			}
		}
	}
	
	// �����ϰ�:
	public void paint(Graphics barrier){ // �ú�������ʵ���ϰ���ͼƬ����ӣ������������
		super.paint(barrier);
		Graphics2D barrier2d=(Graphics2D) barrier;
		Image background=getToolkit().getImage("background.jpg");
		barrier2d.drawImage(background, 0, 0, null);
		Image barrier1=getToolkit().getImage("barrier1.png");
		Image barrier2=getToolkit().getImage("barrier2.png");
		Image barrier3=getToolkit().getImage("barrier3.png");
		Image firework=getToolkit().getImage("boom.png");
		for(int i=0;i<20;i++){
			for(int j=0;j<20;j++){
				if(Barrier.place[i][j]==1){
					barrier2d.drawImage(barrier1, j*30, i*30, null);
				}
				if(Barrier.place[i][j]==2){
					barrier2d.drawImage(barrier2, j*30, i*30, null);
				}
				if(Barrier.place[i][j]==3){
					barrier2d.drawImage(barrier3, j*30, i*30, null);
				}
				if(Barrier.place[i][j]==7){
					barrier2d.drawImage(firework, j*30, i*30, null);
				}
			}
		}
	}
	
	// ��ʼ������:
	public static void createplace(){
		for(int i=0;i<20;i++){ // ��ѭ��ʵ�ֶ�ά��������������ķ��࣬����Ϊ���࣬���������������ϰ���
			for(int j=0;j<20;j++){
				if(i==0||i==19|j==0|j==19){
					Barrier.place[i][j]=1; // ����Χ�߽���Ϊ1
					continue;
				}
				int setBarrier=(int)(4*Math.random()); // �����������ʵ����һ��4���ϰ�����������
				if(setBarrier==1){
					Barrier.place[i][j]=0; // �������Ϊ1��Ҳ����Ϊ0����Ϊ�յ�
					continue;
				}
				Barrier.place[i][j]=setBarrier; // �����Ϊ2��3�����ɶ�Ӧ���ϰ���
			}
		}
		
		// ��ɫ���������벻��������ͬ����֤��ʼ�ļ����ط����붼�ǿյ�:
		Barrier.place[1][1]=0;
		Barrier.place[1][2]=0;
		Barrier.place[2][1]=0;
		
		// ���ɵ���:
		for(int i=0;i<WinOrLose.num_enemy;i++){ // ��ѭ��ʵ�ֵ��˳����ص�ѡ��
			int x=(int)(2+Math.random()*17); // ��֤���˲����ڱ߽������ɣ��Ҳ���һ��ʼ�Ͱ����Ǹ�ɱ��
			int y=(int)(2+Math.random()*17);
			Barrier.place[x][y]=4; // ��������Ϊ4
			// ��֤���˿��������ƶ�:
			if(Barrier.place[x+1][y]!=1) { // ���ǰ����Ϊ��Χ�߽磬����Ϊ�յ�
				Barrier.place[x+1][y]=0;
			}
			if(Barrier.place[x-1][y]!=1) {
				Barrier.place[x-1][y]=0;
			}
			if(Barrier.place[x][y+1]!=1) {
				Barrier.place[x][y+1]=0;
			}
			if(Barrier.place[x][y-1]!=1) {
				Barrier.place[x][y-1]=0;
			}
		}
	}
}
