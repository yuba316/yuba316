import java.awt.Menu;
import java.awt.MenuBar;
import java.awt.MenuItem;
import java.awt.event.*;
import javax.swing.*;

public class Framework extends JFrame implements ActionListener{
	/**
	 * ����ʵ����Ϸ��ʼ������������
	 */
	private static final long serialVersionUID = -6718388110822790482L; // �Ҳ�֪������Ǹ���ģ���ֻ�Ǹ���java����ʾ�����������
	public static JLabel score; // �÷�
	public static JLabel power; // ը������
	public JLabel background; // ����ͼ
	JPanel panel;
	
	// ���ò˵���:
	private MenuBar mb;
	private Menu game;
	private MenuItem start; // ��ʼ��Ϸ
	private MenuItem again; // ���¿�ʼ
	private MenuItem quit; // �˳���Ϸ
	private Gameframework gameframe;

	public static boolean Start=false;
	public Framework(){
		// �ο����� java.awt.Menu��ʹ��. https://www.oschina.net/uploads/doc/javase-6-doc-api-zh_CN/java/awt/class-use/Menu.html.

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
		score=new JLabel("score��"+Bomb.score);
		score.setBounds(0, 600, 60, 20);
		power=new JLabel("power��"+Bomb.power);
		power.setBounds(540, 600, 60, 20);
		add(score);
		add(power);
		addWindowListener(new close());
	}
	
	// ���ô���:
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
		 * ����ʵ�ֿ�ʼ��Ϸ��Ľ������
		 */
		private static final long serialVersionUID = -2176911524080949223L;

		public Gameframework() {
			setLayout(null);
			WinOrLose initial = new WinOrLose(); // ��ʼ��������Ϸ���������WinOrLose��
			initial.setBounds(0, 0, 600, 600);
			add(initial);
		}
	}
	
	// �˳���Ϸ:
	class close extends WindowAdapter{
		public void windowClosing(WindowEvent e){
			System.exit(0);
		}
	}
	
	// ��ʼ��Ϸ:
	@Override
	public void actionPerformed(ActionEvent e) {
		// TODO Auto-generated method stub
		if(Start==false){
			if(e.getActionCommand().equals("start")){
				gameframe=new Gameframework(); // ������Ϸ����
				gameframe.setBounds(0, 0, 600, 600);
				add(gameframe);
				this.repaint();
				Start=true;
			}
		}
		if(e.getActionCommand().equals("again")){
			creategame(); // ���³�ʼ����Ϸ
		}
		if(e.getActionCommand().equals("quit")){
			System.exit(0);
		}
	}
		
	// ��ʼ����Ϸ:
	public static void creategame(){
		Character.nowy=6; // ���ǳ�����
		Character.nowx=6;
		Barrier.createplace(); // ��ʼ�����أ����Barrier��
		WinOrLose.EnemyList.clear(); // ��յ����б�
		WinOrLose.createenemy(); // ��ʼ�����ˣ����Enemy��
		WinOrLose.gg=true; // ��δ������Ϸ
		Character.death=false; // ���ǻ�δ����
		Bomb.score=0; // �÷�����
		Framework.score.setText("score��"+Bomb.score);
		Bomb.power=WinOrLose.power; // ը���ȼ���Ϊ2
		Framework.power.setText("power��"+Bomb.power);		
	}	
}