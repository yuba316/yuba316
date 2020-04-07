import java.awt.Menu;
import java.awt.MenuBar;
import java.awt.MenuItem;
import java.awt.event.*;
import javax.swing.*;

public class Framework extends JFrame implements ActionListener{
	/**
	 * 该类实现游戏开始界面的所有设计
	 */
	private static final long serialVersionUID = -6718388110822790482L; // 我不知道这个是干嘛的，我只是根据java的提示就生成了这个
	public static JLabel score; // 得分
	public static JLabel power; // 炸弹威力
	public JLabel background; // 背景图
	JPanel panel;
	
	// 设置菜单栏:
	private MenuBar mb;
	private Menu game;
	private MenuItem start; // 开始游戏
	private MenuItem again; // 重新开始
	private MenuItem quit; // 退出游戏
	private Gameframework gameframe;

	public static boolean Start=false;
	public Framework(){
		// 参考自类 java.awt.Menu的使用. https://www.oschina.net/uploads/doc/javase-6-doc-api-zh_CN/java/awt/class-use/Menu.html.

		setFramework();
		mb=new MenuBar();
		game=new Menu("menu");
		start=new MenuItem("start");
		again=new MenuItem("again");
		quit=new MenuItem("quit");
		start.addActionListener(this);
		again.addActionListener(this);
		quit.addActionListener(this);
		game.add(start);
		game.add(again);
		game.add(quit);
		mb.add(game);
		setMenuBar(mb);
		score=new JLabel("score："+Bomb.score);
		score.setBounds(0, 600, 60, 20);
		power=new JLabel("power："+Bomb.power);
		power.setBounds(540, 600, 60, 20);
		add(score);
		add(power);
		addWindowListener(new close());
	}
	
	// 设置窗口:
	private void setFramework() {
		setLayout(null);
		setTitle("Avengers");
		setSize(615, 680);
		setLocationRelativeTo(null);
		setResizable(false);
		setVisible(true);
		panel = new JPanel();
		JLabel label = new JLabel();
		ImageIcon img = new ImageIcon("menu.jpg");
		label.setIcon(img);
		panel.add(label);
		panel.setBounds(0, 145, 600, 293);
		getContentPane().add(panel);	
	}
	
	class Gameframework extends JPanel{
		/**
		 * 该类实现开始游戏后的界面设计
		 */
		private static final long serialVersionUID = -2176911524080949223L;

		public Gameframework() {
			setLayout(null);
			WinOrLose initial = new WinOrLose(); // 初始化所有游戏场景，详见WinOrLose类
			initial.setBounds(0, 0, 600, 600);
			add(initial);
		}
	}
	
	// 退出游戏:
	class close extends WindowAdapter{
		public void windowClosing(WindowEvent e){
			System.exit(0);
		}
	}
	
	// 开始游戏:
	@Override
	public void actionPerformed(ActionEvent e) {
		// TODO Auto-generated method stub
		if(Start==false){
			if(e.getActionCommand().equals("start")){
				gameframe=new Gameframework(); // 进入游戏界面
				gameframe.setBounds(0, 0, 600, 600);
				add(gameframe);
				this.repaint();
				Start=true;
			}
		}
		if(e.getActionCommand().equals("again")){
			creategame(); // 重新初始化游戏
		}
		if(e.getActionCommand().equals("quit")){
			System.exit(0);
		}
	}
		
	// 初始化游戏:
	public static void creategame(){
		Character.nowy=6; // 主角出生地
		Character.nowx=6;
		Barrier.createplace(); // 初始化场地，详见Barrier类
		WinOrLose.EnemyList.clear(); // 清空敌人列表
		WinOrLose.createenemy(); // 初始化敌人，详见Enemy类
		WinOrLose.gg=true; // 还未结束游戏
		Character.death=false; // 主角还未死亡
		Bomb.score=0; // 得分清零
		Framework.score.setText("score："+Bomb.score);
		Bomb.power=WinOrLose.power; // 炸弹等级还为2
		Framework.power.setText("power："+Bomb.power);		
	}	
}