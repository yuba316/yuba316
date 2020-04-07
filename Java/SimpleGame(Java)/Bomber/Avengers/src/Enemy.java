import java.awt.Rectangle;

public class Enemy implements Runnable{ // 该类主要实现敌人的生死、移动以及与爆炸火花、障碍物和主角的碰撞检测
	boolean alive=true; // 敌人的生死
	private int direction;
	private int x; // 敌人当前坐标
	private int y;
	public int getx() {
		return x;
	}
	public int gety() {
		return y;
	}
	public void setx(int x) {
		this.x = x;
	}
	public void sety(int y) {
		this.y = y;
	}
	public Enemy(int x,int y){
		setx(x);
		sety(y);
	}
	
	// 敌人的移动方向:
	public void waytoward(){
		boolean crash=true;
		while(crash) {
			direction = (int)(Math.random()*4);
			if(direction==0){
				 int xEnemy=getx()/6-1; // 敌人下一步坐标，敌人为坐标点的6倍，故应该除以6得到其坐标
				 if(Barrier.place[xEnemy][gety()/6]==0){ // 如果下一步为空地，则可以移动
					 crash=false;
				 }
			 }
			 if(direction==1){
				 int yEnemy=gety()/6+1;
				 if(Barrier.place[getx()/6][yEnemy]==0){
					 crash=false;
				 }
			 }
			 if(direction==2){
				 int xEnemy=getx()/6+1;
				 if(Barrier.place[xEnemy][gety()/6]==0){
					 crash=false;
				 }
			 }
			 if(direction==3){
				 int yEnemy=gety()/6-1;
				 if(Barrier.place[getx()/6][yEnemy]==0){
					 crash=false;
				 }
			 }
		}
	}
	
	// 敌人移动:
	public void moving(int direction){
		switch (direction) {
        case 0:
            for(int i=0;i<6;i++){ // 原坐标点被放大了6倍，而敌人每次只移动一小步
                setx(getx() - 1);
                getkill(); // 判断敌人是否被杀
                try {
                    Thread.sleep(150); // 每次移动耗费150
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            break;
        case 1:
            for(int i=0;i<6;i++){
                sety(gety() + 1);
                getkill();
                try {
                    Thread.sleep(150);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            break;
        case 2:
            for(int i=0;i<6;i++){
                setx(getx() + 1);
                getkill();
                try {
                    Thread.sleep(150);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            break;
        case 3:
            for(int i=0;i<6;i++){
                sety(gety() - 1);
                getkill();
                try {
                    Thread.sleep(150);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            break;
        default:
            break;
		}
	}
	
	// 运行多线程:
	public void run() {
		 while (true) {
			waytoward(); // 得到敌人的移动方向
		        try {
		            Thread.sleep(50); // 两次移动间休息50
		        } catch (Exception e) {
		            e.printStackTrace();
		        }
		        moving(direction); // 敌人移动

		        if(alive==false){ // 敌人被杀则加分
		        	Bomb.score+=100;
		        	Framework.score.setText("score："+Bomb.score);
		            break;
		        }
		 }
	}
	
	// 敌人被杀:
	// 参考自https://stackoverflow.com/questions/8472148/java-rectangle-intersect-method. Stack overflow. rmp2150. Java Rectangle Intersect Method. 2011.12.12 9:21.

	private boolean killing(Rectangle boom){
		return this.setEnemy(getx(),gety()).intersects(boom); // 爆炸火花碰撞检测
	}
	private boolean getkill(){ // 如果敌人所在位置小于爆炸火花特效的范围，则被炸死
		Barrier body=new Barrier();	
		for(int i=0;i<body.getfirework().size();i++){
			if(killing(body.getfirework().get(i))){
				alive=false;
				break;
			}
		}
		return alive;	
	}
	
	// 绘制敌人:
	private Rectangle setEnemy(int x, int y) {
		return new Rectangle(y*5, x*5,30, 30);
	} 
	public Rectangle getEnemy(){
		return new Rectangle(gety()*5, getx()*5, 30, 30);
	}
}
