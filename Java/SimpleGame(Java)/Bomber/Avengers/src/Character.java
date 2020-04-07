import java.awt.*;
import java.awt.event.*;

public class Character extends Barrier implements KeyListener{
	/**
	 * 该类主要实现主角的生死、移动以及与爆炸火花、障碍物和敌人的碰撞检测
	 */
	private static final long serialVersionUID = 8124313409865134983L; // 我不知道这个是干嘛的，我只是根据java的提示就生成了这个
	private Barrier barrier;
	private Barrier body;
	public static int nowx=6; // 主角当前坐标
	public static int nowy=6;
	public static int getnowx(){
		return nowx;
	}
	public static int getnowy(){
		return nowy;
	}
	private int nextx=0; // 主角下一步坐标
	private int nexty=0;
	private boolean noway=false; // 主角是否撞墙
	public static boolean death=false; // 主角的生死
	private boolean up;
	private boolean down;
	private boolean right;
	private boolean left;
	
	// 绘制主角:
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

		// 主角生死判断:
		for(int i=0;i<body.getfirework().size();i++){ // 如果主角所在位置小于爆炸火花特效的范围，则被炸死
			if(crashbombnext(body.getfirework().get(i))){ // 爆炸火花碰撞检测
				death=true;
				break;
			}
		}
		
		Image character=getToolkit().getImage("character.png");
		human.drawImage(character, 5*nowy, 5*nowx, null);
		playerMove();
	}
	
	// 主角移动:
	public void playerMove(){ // 该函数实现主角的移动，主要思路是判断主角下一步是否撞墙
		if(up==true){
			if(nowx>6){
				barrier=new Barrier();
				nextx=getnowx()-1;
				nexty=getnowy();
				noway=false;
				for(int i=0;i<barrier.getBarrier().size();i++){
					if(crashwallnext(barrier.getBarrier().get(i))){ // 障碍物碰撞检测
						noway=true; // 主角撞墙
						break;
					}
				}
				if(noway==false){ // 主角不撞墙，则当前坐标减1
					nowx=nowx-1;
				}
			}
		}
		if(down==true){
			if(nowx<108){ // 主角为坐标点的6倍，故为了防止撞到外围边界，则移动范围必须小于6*(20-2)
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
	
	// 碰撞检测，主要思路是判断两矩形是否相交:
	public Rectangle getnowcharacter(int x,int y){ // 得到主角当前坐标
		return new Rectangle(y*5, x*5, 30, 30);
	}
	public Rectangle getnextcharacter(){ // 得到主角下一步坐标
		return new Rectangle(this.nexty*5, this.nextx*5, 30, 30);
	}
	public boolean crashwallnext(Rectangle barrier){ // 障碍物碰撞检测
		return this.getnextcharacter().intersects(barrier);
	}
	public boolean crashbombnext(Rectangle bomb){ // 爆炸火花碰撞检测
		return this.getnowcharacter(getnowx(),getnowy()).intersects(bomb);
	}
	public static Rectangle crashenemy(){ // 敌人碰撞检测
		return new Rectangle(getnowy()*5, getnowx()*5, 30, 30);
	}
	
	// 键盘操作:
	// 参考自https://blog.csdn.net/qq_36761831/article/details/81545050. CSDN. Hern（宋兆恒）. Java KeyEvent（键盘事件）. 2018.08.09 22:22.
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
