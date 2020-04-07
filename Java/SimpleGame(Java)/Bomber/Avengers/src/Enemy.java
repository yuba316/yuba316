import java.awt.Rectangle;

public class Enemy implements Runnable{ // ������Ҫʵ�ֵ��˵��������ƶ��Լ��뱬ը�𻨡��ϰ�������ǵ���ײ���
	boolean alive=true; // ���˵�����
	private int direction;
	private int x; // ���˵�ǰ����
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
	
	// ���˵��ƶ�����:
	public void waytoward(){
		boolean crash=true;
		while(crash) {
			direction = (int)(Math.random()*4);
			if(direction==0){
				 int xEnemy=getx()/6-1; // ������һ�����꣬����Ϊ������6������Ӧ�ó���6�õ�������
				 if(Barrier.place[xEnemy][gety()/6]==0){ // �����һ��Ϊ�յأ�������ƶ�
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
	
	// �����ƶ�:
	public void moving(int direction){
		switch (direction) {
        case 0:
            for(int i=0;i<6;i++){ // ԭ����㱻�Ŵ���6����������ÿ��ֻ�ƶ�һС��
                setx(getx() - 1);
                getkill(); // �жϵ����Ƿ�ɱ
                try {
                    Thread.sleep(150); // ÿ���ƶ��ķ�150
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
	
	// ���ж��߳�:
	public void run() {
		 while (true) {
			waytoward(); // �õ����˵��ƶ�����
		        try {
		            Thread.sleep(50); // �����ƶ�����Ϣ50
		        } catch (Exception e) {
		            e.printStackTrace();
		        }
		        moving(direction); // �����ƶ�

		        if(alive==false){ // ���˱�ɱ��ӷ�
		        	Bomb.score+=100;
		        	Framework.score.setText("score��"+Bomb.score);
		            break;
		        }
		 }
	}
	
	// ���˱�ɱ:
	// �ο���https://stackoverflow.com/questions/8472148/java-rectangle-intersect-method. Stack overflow. rmp2150. Java Rectangle Intersect Method. 2011.12.12 9:21.

	private boolean killing(Rectangle boom){
		return this.setEnemy(getx(),gety()).intersects(boom); // ��ը����ײ���
	}
	private boolean getkill(){ // �����������λ��С�ڱ�ը����Ч�ķ�Χ����ը��
		Barrier body=new Barrier();	
		for(int i=0;i<body.getfirework().size();i++){
			if(killing(body.getfirework().get(i))){
				alive=false;
				break;
			}
		}
		return alive;	
	}
	
	// ���Ƶ���:
	private Rectangle setEnemy(int x, int y) {
		return new Rectangle(y*5, x*5,30, 30);
	} 
	public Rectangle getEnemy(){
		return new Rectangle(gety()*5, getx()*5, 30, 30);
	}
}
