import java.awt.Graphics;
import java.awt.Image;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JLabel;

public class WinOrLose extends Bomb implements Runnable,ActionListener{
	/**
	 * 该类实现所有游戏场景的初始化
	 */
	private static final long serialVersionUID = -964036654185127258L; // 我不知道这个是干嘛的，我只是根据java的提示就生成了这个
	public static int num_enemy=3; // 第一关敌人只有3个，用在Barrier类中生成敌人的出生地
	public static int power=2; // 第一关炸弹威力只有2，用在Bomb类中确定炸弹爆炸后的火花特效范围
	public static boolean gg=true; // 判断游戏是否gg(结束与否，true为还未结束)
	public static ArrayList<Enemy> EnemyList; // 生成敌人列表
	JDialog win; // 生成输赢窗口
	JDialog lose;
	
	public WinOrLose(){
		this.setFocusable(true);
		EnemyList=new ArrayList<Enemy>();
		createenemy(); // 生成敌人
		Thread plane1=new Thread(this);
		plane1.start();	
	}
	
	// 生成敌人:
	public static void createenemy(){
		for(int i=0;i<20;i++){
			for(int j=0;j<20;j++){
				if(Barrier.place[i][j]==4){ // 地图中为4的网格即为敌人的出生地，详见Barrier类
				Enemy ene=new Enemy(i*6, j*6); // 敌人为坐标点的6倍
				Thread ene1=new Thread(ene);
				Barrier.place[i][j]=0; // 将敌人出生地设置为空地
				ene1.start();
				EnemyList.add(ene); // 新增敌人到列表中去
				}
			}
		}
	}
	
	public void paint(Graphics enemy){
		super.paint(enemy);
		Image Enemies=getToolkit().getImage("enemy.png"); 
		for(int i=0;i<EnemyList.size();i++){
			if(EnemyList.get(i).alive==true){ // 判断敌人死活，活着则绘制敌人画像
				enemy.drawImage(Enemies, EnemyList.get(i).gety()*5, EnemyList.get(i).getx()*5, 30, 30, null);
			}else{
				EnemyList.remove(i); // 死亡敌人从列表中移除
			}
		}
		// 敌人碰撞检测:
		for(int i=0;i<EnemyList.size();i++){
			if(EnemyList.get(i).getEnemy().intersects(Character.crashenemy())){
				Character.death=true; // 如果撞到敌人，则主角死亡
			}
		}
	}
	
	// 运行多线程:
	// 参考自https://www.cnblogs.com/riskyer/p/3263032.html. 博客园. you Richer. Java线程详解.
	@Override
	public void run() {
		// TODO Auto-generated method stub
		while(true){
			try {
				Thread.sleep(50);
			} catch (InterruptedException e) {
				// TODO Auto-generated method stub
				e.printStackTrace();
			}
			if(gg==true){ // 如果游戏还在进行
				repaint();
				if(EnemyList.size()==0){ // 杀光敌人则胜利
					win(); // 跳出胜利窗口，可进入下一关
					gg=false; // 中断游戏
				}
				if(Character.death==true){ // 主角死亡则失败
					Bomb.bombexist=false; // 炸弹清空
					Bomb.timecount=0; // 计时归零
					lose(); // 跳出失败窗口
					gg=false; // 中断游戏
				}
			}	
		}
	}
	
	// 胜利窗口:
	private void win() {
		win = new JDialog();
		win.setSize(516, 246);
		win.setLocationRelativeTo(null);
		win.setLayout(null);
		JLabel info = new JLabel(new ImageIcon("win.jpg"));
		info.setBounds(0, 0, 501, 176);
		JLabel gameinfo = new JLabel("score："+Bomb.score);
		gameinfo.setBounds(90, 176, 100, 30);
		JButton butun1=new JButton("next"); // 进入下一关
		butun1.setBounds(0, 176, 90, 30);
		butun1.addActionListener(this);
		win.add(butun1);
		win.add(info);
		win.add(gameinfo);
		win.setVisible(true);
	}
	
	// 失败窗口:
	private void lose() {
		lose = new JDialog();
		lose.setSize(480, 300);
		lose.setLocationRelativeTo(null);
		lose.setLayout(null);
		JLabel info2 = new JLabel(new ImageIcon("lose.jpg"));
		info2.setBounds(0, 0, 465, 230);
		JLabel gameinfo2 = new JLabel("score："+Bomb.score);
		gameinfo2.setBounds(100, 230, 90, 30);
		lose.add(info2);
		lose.add(gameinfo2);
		JButton butun2=new JButton("again");
		butun2.setBounds(0, 230, 90, 30);
		butun2.addActionListener(this);
		lose.add(butun2);
		lose.setVisible(true);
	}
	
	// 鼠标点击:
	@Override
	public void actionPerformed(ActionEvent e) {
		// TODO Auto-generated method stub
		if(e.getActionCommand().equals("again")){
			Framework.creategame(); // 重新初始化游戏
			lose.dispose(); // 窗口消失
		}
		if(e.getActionCommand().equals("next")){
			num_enemy=num_enemy+2; // 下一关敌人数目加2
			power=power+1; // 通关后炸弹威力加1，可摧毁墙壁，详见Barrier类
			Framework.creategame(); // 重新初始化游戏
			win.dispose(); // 窗口消失
		}
	}
}
