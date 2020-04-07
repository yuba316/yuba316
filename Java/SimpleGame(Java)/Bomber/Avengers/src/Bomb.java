import java.awt.AWTEvent;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.Toolkit;
import java.awt.event.AWTEventListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;

public class Bomb extends Character implements KeyListener{
	/**
	 * ������Ҫʵ��ը����ը��Ļ𻨴ݻٸ����ϰ���Ĺ���
	 */
	private static final long serialVersionUID = 8709360091601455833L; // �Ҳ�֪������Ǹ���ģ���ֻ�Ǹ���java����ʾ�����������
	public Bomb(){
		addKeyListener(this);
	}
	
	// ����ը��:
	public static int power=WinOrLose.power; // ը������
	public static int score=0; // �÷�
	private int Bombx; // ը������
	private int Bomby;
	public int getBombwidth() {
		return Bombx;
	}
	public int getBomblength() {
		return Bomby;
	}
	public static int timecount=0; // ը���ӱ����ŵ���ը��Ļ𻨳���ʱ��
	public static boolean bombexist=false; // ��Ϸ���Ƿ��Ѵ���ը��
	private boolean bombset=false; // �����Ƿ��Ѿ����Ź�ը��
	private boolean up=true; // ը����ը��Ļ𻨷���
	private boolean down=true;
	private boolean right=true;
	private boolean left=true;

	public void paint(Graphics boom){
		super.paint(boom);
		Toolkit.getDefaultToolkit().addAWTEventListener(new AWTEventListener() {  
	        @Override  
	        public void eventDispatched(AWTEvent event) {  
	            // TODO Auto-generated method stub  
	            if(((KeyEvent)event).getID()==KeyEvent.KEY_TYPED){  
	            	if(bombexist==false){ // ֻ������Ϸ�в�����ը��ʱ���ܰ���
	        			int space = ((KeyEvent)event).getKeyChar();
	        			if(space==32){
	        				Bomby=Character.getnowy()/6; // ը��Ϊ������6������Ӧ�ó���6�õ�������
	        				Bombx=Character.getnowx()/6;
	        				bombexist=true;
	        			}
	        		}
	            } 
	            
	        }  
	    }, AWTEvent.KEY_EVENT_MASK);  
		Image bomb=getToolkit().getImage("bomb.png");
		if(bombexist==true){ // �����Ѿ����Ź�ը��
			timecount++;
			if(timecount<40){ // ��ʱС��40ʱ������ʾը����ͼƬ������δ��ը
			boom.drawImage(bomb, 30*Bomby, 30*Bombx, 30, 30, null);
			}
			if(timecount>=40&&timecount<50){ // ը����ը��Ļ𻨳���ʱ��Ϊ10
				if(bombset==false){
					explode(); // ��ը�𻨴ݻٸ����ϰ���
				}
			}
			if(timecount==50){ // ը����ȴ����������װ��
				createbomb(); // Ϊ��������ը��
			}
		}
	}

	// ��ը�𻨴ݻٸ����ϰ���:
	public void explode(){
		bombexist=true; // ��Ϸ�д���ը��
		Barrier.place[getBombwidth()][getBomblength()]=7;
		for(int i=0;i<power;i++){ // ����ը������ȷ����ը��Χ,������Ч������
			if(up){
				int xarea=getBombwidth()-1-i;
				if(xarea<0){ // ���ը������Χ�߽�����Ч
					xarea=0;
				}
				// ��0���ϰ���Ϊ�յأ���2���ϰ�Ϊ�ɴݻٵ�ǽ�ڣ���3���ϰ�Ϊ���ɴݻٵ�ǽ�� 
				if(Barrier.place[xarea][getBomblength()]==0||Barrier.place[xarea][getBomblength()]==2||Barrier.place[xarea][getBomblength()]==3){
					if(Barrier.place[xarea][getBomblength()]==0){ // ���Ϊ�յأ������Ϊ��ը����Ч
						Barrier.place[xarea][getBomblength()]=7;
					}
					if(Barrier.place[xarea][getBomblength()]==2){ // ���Ϊ�ɴݻٵ�ǽ�ڣ������Ϊ�յ�
						Barrier.place[xarea][getBomblength()]=0;
						score=score+10;
						Framework.score.setText("score��"+Bomb.score);
						up=false; // �Ѿ��ݻ��ϰ����ˣ���������ǰ��������Ч������
					}
					if(Barrier.place[xarea][getBomblength()]==3){ // ���Ϊ���ɴݻٵ�ǽ�ڣ���һ��ը�ٱ�Ϊ�ɴݻٵ�ǽ��
						Barrier.place[xarea][getBomblength()]=2;
						up=false;
					}
				}
			}
			if(down){
				int xarea=getBombwidth()+1+i;
				if(xarea>19){
					xarea=19;
				}
				if(Barrier.place[xarea][getBomblength()]==0||Barrier.place[xarea][getBomblength()]==2||Barrier.place[xarea][getBomblength()]==3){
					if(Barrier.place[xarea][getBomblength()]==0){ 
						Barrier.place[xarea][getBomblength()]=7;
					}
					if(Barrier.place[xarea][getBomblength()]==2){
						Barrier.place[xarea][getBomblength()]=0;
						score=score+10;
						Framework.score.setText("score��"+Bomb.score);
						down=false;
					}
					if(Barrier.place[xarea][getBomblength()]==3){
						Barrier.place[xarea][getBomblength()]=2;
						down=false;
					}
				}
			}
			if(right){
				int yarea=getBomblength()+1+i;
				if(yarea>19){
					yarea=19;
				}
				if(Barrier.place[getBombwidth()][yarea]==0||Barrier.place[getBombwidth()][yarea]==2||Barrier.place[getBombwidth()][yarea]==3){
					if(Barrier.place[getBombwidth()][yarea]==0){
						Barrier.place[getBombwidth()][yarea]=7;
					}
					if(Barrier.place[getBombwidth()][yarea]==2){
						Barrier.place[getBombwidth()][yarea]=0;
						score=score+10;//�ӷ�
						Framework.score.setText("score��"+Bomb.score);
						right=false;
					}
					if(Barrier.place[getBombwidth()][yarea]==3){
						Barrier.place[getBombwidth()][yarea]=2;
						right=false;
					}
				}
			}
			if(left){
				int yarea=getBomblength()-1-i;
				if(yarea<0){
					yarea=0;
				}
				if(Barrier.place[getBombwidth()][yarea]==0||Barrier.place[getBombwidth()][yarea]==2||Barrier.place[getBombwidth()][yarea]==3){
					if(Barrier.place[getBombwidth()][yarea]==0){
						Barrier.place[getBombwidth()][yarea]=7;
					}
					if(Barrier.place[getBombwidth()][yarea]==2){
						Barrier.place[getBombwidth()][yarea]=0;
						score=score+10;
						Framework.score.setText("score��"+Bomb.score);
						left=false;
					}
					if(Barrier.place[getBombwidth()][yarea]==3){
						Barrier.place[getBombwidth()][yarea]=2;
						left=false;
					}
				}
			}
		}
	}
	
	// ��ʼ��ը��:
	public void createbomb(){
		bombexist=false;
		timecount=0;
		up=true;
		down=true;
		right=true;
		left=true;
		bombset=false;
		for(int i=0;i<20;i++){
			for(int j=0;j<20;j++){
				if(Barrier.place[i][j]==7){
					Barrier.place[i][j]=0;
				}
			}
		}
	}
}
