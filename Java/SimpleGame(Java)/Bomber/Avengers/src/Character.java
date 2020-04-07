import java.awt.*;
import java.awt.event.*;

public class Character extends Barrier implements KeyListener{
	/**
	 * ������Ҫʵ�����ǵ��������ƶ��Լ��뱬ը�𻨡��ϰ���͵��˵���ײ���
	 */
	private static final long serialVersionUID = 8124313409865134983L; // �Ҳ�֪������Ǹ���ģ���ֻ�Ǹ���java����ʾ�����������
	private Barrier barrier;
	private Barrier body;
	public static int nowx=6; // ���ǵ�ǰ����
	public static int nowy=6;
	public static int getnowx(){
		return nowx;
	}
	public static int getnowy(){
		return nowy;
	}
	private int nextx=0; // ������һ������
	private int nexty=0;
	private boolean noway=false; // �����Ƿ�ײǽ
	public static boolean death=false; // ���ǵ�����
	private boolean up;
	private boolean down;
	private boolean right;
	private boolean left;
	
	// ��������:
	public void paint(Graphics human){
		super.paint(human);
		body=new Barrier();	
		// copy:
		Toolkit.getDefaultToolkit().addAWTEventListener(new AWTEventListener() {
	        public void eventDispatched(AWTEvent event) {
	            if(((KeyEvent)event).getID()==KeyEvent.KEY_PRESSED){  
	            	int key=((KeyEvent)event).getKeyCode();
	        		movePressed(key);
	            } 
	            if(((KeyEvent)event).getID()==KeyEvent.KEY_RELEASED){  
	            	int key=((KeyEvent)event).getKeyCode();
	        		moveReleased(key);
	            }  
	        }  
	    }, AWTEvent.KEY_EVENT_MASK);  

		// ���������ж�:
		for(int i=0;i<body.getfirework().size();i++){ // �����������λ��С�ڱ�ը����Ч�ķ�Χ����ը��
			if(crashbombnext(body.getfirework().get(i))){ // ��ը����ײ���
				death=true;
				break;
			}
		}
		
		Image character=getToolkit().getImage("character.png");
		human.drawImage(character, 5*nowy, 5*nowx, null);
		playerMove();
	}
	
	// �����ƶ�:
	public void playerMove(){ // �ú���ʵ�����ǵ��ƶ�����Ҫ˼·���ж�������һ���Ƿ�ײǽ
		if(up==true){
			if(nowx>6){
				barrier=new Barrier();
				nextx=getnowx()-1;
				nexty=getnowy();
				noway=false;
				for(int i=0;i<barrier.getBarrier().size();i++){
					if(crashwallnext(barrier.getBarrier().get(i))){ // �ϰ�����ײ���
						noway=true; // ����ײǽ
						break;
					}
				}
				if(noway==false){ // ���ǲ�ײǽ����ǰ�����1
					nowx=nowx-1;
				}
			}
		}
		if(down==true){
			if(nowx<108){ // ����Ϊ������6������Ϊ�˷�ֹײ����Χ�߽磬���ƶ���Χ����С��6*(20-2)
				barrier=new Barrier();
				nextx=getnowx()+1;
				nexty=getnowy();
				noway=false;
				for(int i=0;i<barrier.getBarrier().size();i++){
					if(crashwallnext(barrier.getBarrier().get(i))){
						noway=true;
						break;
					}
				}
				if(noway==false){
					nowx=nowx+1;
				}
			}
		}
		if(right==true){
			if(nowy<138){
				barrier=new Barrier();
				nextx=getnowx();
				nexty=getnowy()+1;
				noway=false;
				for(int i=0;i<barrier.getBarrier().size();i++){
					if(crashwallnext(barrier.getBarrier().get(i))){
						noway=true;
						break;
					}
				}
				if(noway==false){
					nowy=nowy+1;
				}
			}
		}
		if(left==true){
			if(nowy>6){
				barrier=new Barrier();
				noway=false;
				nextx=getnowx();
				nexty=getnowy()-1;
				for(int i=0;i<barrier.getBarrier().size();i++){
					if(crashwallnext(barrier.getBarrier().get(i))){
						noway=true;
						break;
					}
				}
				if(noway==false){
					nowy=nowy-1;
				}
			}
		}
	}
	
	// ��ײ��⣬��Ҫ˼·���ж��������Ƿ��ཻ:
	public Rectangle getnowcharacter(int x,int y){ // �õ����ǵ�ǰ����
		return new Rectangle(y*5, x*5, 30, 30);
	}
	public Rectangle getnextcharacter(){ // �õ�������һ������
		return new Rectangle(this.nexty*5, this.nextx*5, 30, 30);
	}
	public boolean crashwallnext(Rectangle barrier){ // �ϰ�����ײ���
		return this.getnextcharacter().intersects(barrier);
	}
	public boolean crashbombnext(Rectangle bomb){ // ��ը����ײ���
		return this.getnowcharacter(getnowx(),getnowy()).intersects(bomb);
	}
	public static Rectangle crashenemy(){ // ������ײ���
		return new Rectangle(getnowy()*5, getnowx()*5, 30, 30);
	}
	
	// ���̲���:
	// �ο���https://blog.csdn.net/qq_36761831/article/details/81545050. CSDN. Hern�����׺㣩. Java KeyEvent�������¼���. 2018.08.09 22:22.
	public void movePressed(int keycode){
		switch(keycode){
		case KeyEvent.VK_UP:
			up=true;
			break;
		case KeyEvent.VK_DOWN:
			down=true;
			break;
		case KeyEvent.VK_RIGHT:
			right=true;
			break;
		case KeyEvent.VK_LEFT:
			left=true;
			break;
		}
	}
	public void moveReleased(int keycode){
		switch(keycode){
		case KeyEvent.VK_UP:
			up=false;
			break;
		case KeyEvent.VK_DOWN:
			down=false;
			break;
		case KeyEvent.VK_RIGHT:
			right=false;
			break;
		case KeyEvent.VK_LEFT:
			left=false;
			break;
		}
	}

	@Override
	public void keyPressed(KeyEvent arg0) {
		// TODO Auto-generated method stub
		
	}
	@Override
	public void keyReleased(KeyEvent arg0) {
		// TODO Auto-generated method stub
		
	}
	@Override
	public void keyTyped(KeyEvent arg0) {
		// TODO Auto-generated method stub
		
	}
}
