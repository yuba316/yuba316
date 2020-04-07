import java.util.ArrayList;
import java.awt.Rectangle;
import javax.swing.JPanel;
import java.awt.Image;
import java.awt.Graphics;
import java.awt.Graphics2D;

public class Barrier extends JPanel{
	
	/**
	 * 该类实现3种障碍物的生成
	 * 0为空地;1为外围边界;2和3为矩形障碍物;后两类障碍物的区别将在Bomb类中体现
	 * 4为敌人;7为爆炸火花效果;这两者将在后续Enemy和Bomb类中做详细定义
	 */
	private static final long serialVersionUID = 8258437213281553250L; // 我不知道这个是干嘛的，我只是根据java的提示就生成了这个
	public static int place[][]=new int[20][20]; // 利用数组生成网格场地
	
	static{
		for(int i=0;i<20;i++){ // 该循环实现二维数组里所有网格的分类，共分为四类，决定是生成哪类障碍物
			for(int j=0;j<20;j++){
				if(i==0||i==19|j==0|j==19){
					Barrier.place[i][j]=1; // 将外围边界设为1
					continue;
				}
				int setBarrier=(int)(4*Math.random()); // 利用随机函数实现任一点4种障碍物的随机生成
				if(setBarrier==1){
					Barrier.place[i][j]=0; // 若随机数为1，也设置为0，即为空地
					continue;
				}
				Barrier.place[i][j]=setBarrier; // 随机数为2或3则生成对应的障碍物
			}
		}
		
		// 角色出生地起码不能是死胡同，保证初始的几个地方起码都是空地:
		Barrier.place[1][1]=0;
		Barrier.place[1][2]=0;
		Barrier.place[2][1]=0;
		
		// 生成敌人:
		for(int i=0;i<WinOrLose.num_enemy;i++){ // 该循环实现敌人出生地的选择
			int x=(int)(2+Math.random()*17); // 保证敌人不会在边界上生成，且不会一开始就把主角给杀了
			int y=(int)(2+Math.random()*17);
			Barrier.place[x][y]=4; // 将敌人设为4
			// 保证敌人可以左右移动:
			if(Barrier.place[x+1][y]!=1) { // 如果前方不为外围边界，则设为空地
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
	
	// 生成障碍物:
	// 参考自https://www.jianshu.com/p/7cacc73c96c0. 简书. 轻荷. Particle system_useArrayList & Rectangle. 2015.11.13 22:33.

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
		for(int i=0;i<20;i++){ // 该循环实现所有障碍物1，2，3的生成
			for(int j=0;j<20;j++){
				if(Barrier.place[i][j]==1||Barrier.place[i][j]==2||Barrier.place[i][j]==3){
					BarrierRect.add(new Rectangle(j*30, i*30, 30, 30));
				} // 如果是外围边界或者障碍物2和3，则生成障碍物矩形
				if(Barrier.place[i][j]==7){ // 此为炸弹爆炸后的火花效果，在Bomb类中会做详细阐述，设为7
					firework.add(new Rectangle(j*30, i*30, 30, 30));
				}
			}
		}
	}
	
	// 绘制障碍:
	public void paint(Graphics barrier){ // 该函数仅仅实现障碍物图片的添加，不做过多解释
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
	
	// 初始化场地:
	public static void createplace(){
		for(int i=0;i<20;i++){ // 该循环实现二维数组里所有网格的分类，共分为四类，决定是生成哪类障碍物
			for(int j=0;j<20;j++){
				if(i==0||i==19|j==0|j==19){
					Barrier.place[i][j]=1; // 将外围边界设为1
					continue;
				}
				int setBarrier=(int)(4*Math.random()); // 利用随机函数实现任一点4种障碍物的随机生成
				if(setBarrier==1){
					Barrier.place[i][j]=0; // 若随机数为1，也设置为0，即为空地
					continue;
				}
				Barrier.place[i][j]=setBarrier; // 随机数为2或3则生成对应的障碍物
			}
		}
		
		// 角色出生地起码不能是死胡同，保证初始的几个地方起码都是空地:
		Barrier.place[1][1]=0;
		Barrier.place[1][2]=0;
		Barrier.place[2][1]=0;
		
		// 生成敌人:
		for(int i=0;i<WinOrLose.num_enemy;i++){ // 该循环实现敌人出生地的选择
			int x=(int)(2+Math.random()*17); // 保证敌人不会在边界上生成，且不会一开始就把主角给杀了
			int y=(int)(2+Math.random()*17);
			Barrier.place[x][y]=4; // 将敌人设为4
			// 保证敌人可以左右移动:
			if(Barrier.place[x+1][y]!=1) { // 如果前方不为外围边界，则设为空地
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
