import java.awt.AWTEvent;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.Toolkit;
import java.awt.event.AWTEventListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;

public class Bomb extends Character implements KeyListener{
	/**
	 * 该类主要实现炸弹爆炸后的火花摧毁各类障碍物的功能
	 */
	private static final long serialVersionUID = 8709360091601455833L; // 我不知道这个是干嘛的，我只是根据java的提示就生成了这个
	public Bomb(){
		addKeyListener(this);
	}
	
	// 设置炸弹:
	public static int power=WinOrLose.power; // 炸弹威力
	public static int score=0; // 得分
	private int Bombx; // 炸弹坐标
	private int Bomby;
	public int getBombwidth() {
		return Bombx;
	}
	public int getBomblength() {
		return Bomby;
	}
	public static int timecount=0; // 炸弹从被安放到爆炸后的火花持续时间
	public static boolean bombexist=false; // 游戏中是否已存在炸弹
	private boolean bombset=false; // 主角是否已经安放过炸弹
	private boolean up=true; // 炸弹爆炸后的火花方向
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
	            	if(bombexist==false){ // 只能在游戏中不存在炸弹时才能安放
	        			int space = ((KeyEvent)event).getKeyChar();
	        			if(space==32){
	        				Bomby=Character.getnowy()/6; // 炸弹为坐标点的6倍，故应该除以6得到其坐标
	        				Bombx=Character.getnowx()/6;
	        				bombexist=true;
	        			}
	        		}
	            } 
	            
	        }  
	    }, AWTEvent.KEY_EVENT_MASK);  
		Image bomb=getToolkit().getImage("bomb.png");
		if(bombexist==true){ // 主角已经安放过炸弹
			timecount++;
			if(timecount<40){ // 计时小于40时，则显示炸弹的图片，即尚未爆炸
			boom.drawImage(bomb, 30*Bomby, 30*Bombx, 30, 30, null);
			}
			if(timecount>=40&&timecount<50){ // 炸弹爆炸后的火花持续时间为10
				if(bombset==false){
					explode(); // 爆炸火花摧毁各类障碍物
				}
			}
			if(timecount==50){ // 炸弹冷却结束，重新装填
				createbomb(); // 为主角生成炸弹
			}
		}
	}

	// 爆炸火花摧毁各类障碍物:
	public void explode(){
		bombexist=true; // 游戏中存在炸弹
		Barrier.place[getBombwidth()][getBomblength()]=7;
		for(int i=0;i<power;i++){ // 根据炸弹威力确定爆炸范围,即火花特效矩形数
			if(up){
				int xarea=getBombwidth()-1-i;
				if(xarea<0){ // 如果炸到了外围边界则无效
					xarea=0;
				}
				// 第0类障碍物为空地，第2类障碍为可摧毁的墙壁，第3类障碍为不可摧毁的墙壁 
				if(Barrier.place[xarea][getBomblength()]==0||Barrier.place[xarea][getBomblength()]==2||Barrier.place[xarea][getBomblength()]==3){
					if(Barrier.place[xarea][getBomblength()]==0){ // 如果为空地，则填充为爆炸火花特效
						Barrier.place[xarea][getBomblength()]=7;
					}
					if(Barrier.place[xarea][getBomblength()]==2){ // 如果为可摧毁的墙壁，则填充为空地
						Barrier.place[xarea][getBomblength()]=0;
						score=score+10;
						Framework.score.setText("score："+Bomb.score);
						up=false; // 已经摧毁障碍物了，不可再向前产生火花特效矩形了
					}
					if(Barrier.place[xarea][getBomblength()]==3){ // 如果为不可摧毁的墙壁，则一次炸毁变为可摧毁的墙壁
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
						Framework.score.setText("score："+Bomb.score);
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
						score=score+10;//加分
						Framework.score.setText("score："+Bomb.score);
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
						Framework.score.setText("score："+Bomb.score);
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
	
	// 初始化炸弹:
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
