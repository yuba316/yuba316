package game;

import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import javax.swing.JMenuBar;
import javax.swing.JMenu;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JLabel;
import java.awt.Font;

public class MainFrame extends JFrame implements KeyListener{	//������

	private static final long serialVersionUID = 1L;
	private JPanel contentPane;
	static JLabel statuLabel = new JLabel("��Ϸ��");
	static JLabel scoreLabel = new JLabel("��ǰ����:0");
	JLabel infoLabel1 = new JLabel("F1��ͣ/����");
	JLabel infoLabel2 = new JLabel("F2���¿�ʼ");
	static int stop;		//�ж��Ƿ���ͣ
	static MainFrame mainFrame;
	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		for(int i = 0; i < Grid.WIDHT; i++) 
			for(int j = 0; j < Grid.HEIGHT; j++)Grid.grid[i][j] = new Grid();
		stop = 0;
		mainFrame = new MainFrame();
	}

	/**
	 * Create the frame.
	 */
	public MainFrame() {
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 652, 500);
		addKeyListener(this);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		setContentPane(contentPane);
		contentPane.setLayout(null);
		
		GridPanel gPanel = new GridPanel();
		contentPane.add(gPanel);
		
		JMenuBar menuBar = new JMenuBar();
		menuBar.setBounds(0, 0, 634, 26);
		contentPane.add(menuBar);
		
		JMenu mnNewMenu = new JMenu("New menu");
		menuBar.add(mnNewMenu);
		
		JMenuItem mntmNewMenuItem = new JMenuItem("New menu item");
		mnNewMenu.add(mntmNewMenuItem);
		statuLabel.setFont(new Font("����", Font.PLAIN, 18));
		
		statuLabel.setBounds(464, 97, 72, 18);
		contentPane.add(statuLabel);
		scoreLabel.setFont(new Font("����", Font.PLAIN, 18));
		
		scoreLabel.setBounds(450, 128, 99, 31);
		contentPane.add(scoreLabel);
		infoLabel1.setFont(new Font("����", Font.PLAIN, 18));
		
		infoLabel1.setBounds(410, 366, 99, 31);
		contentPane.add(infoLabel1);
		infoLabel2.setFont(new Font("����", Font.PLAIN, 18));
		
		infoLabel2.setBounds(523, 372, 97, 18);
		contentPane.add(infoLabel2);
		
		this.setVisible(true);
	}
	
	void gameOver() {		//��Ϸ������������ʾ��
		int value = JOptionPane.showConfirmDialog(this, "��Ϸ�������Ƿ����¿�ʼ?","Game Over",JOptionPane.YES_NO_OPTION);
		if(value == JOptionPane.YES_OPTION) {
			reStart();
		}
		else System.exit(0);
	}
	
	void reStart() {		//���¿�ʼ����ʼ�����������
		for(int i = 0; i < Grid.WIDHT; i++) 
			for(int j = 0; j < Grid.HEIGHT; j++)Grid.grid[i][j].clear();
		Snake.head = null;
		Snake.tail = null;
		new Snake();
		Food.food.setFood();
	}

	@Override
	public void keyPressed(KeyEvent e) {	//��ȡ�����¼�
		// TODO Auto-generated method stub
		if(e.getKeyCode() == KeyEvent.VK_F1) {		//�л���ͣ״̬
			stop ^= 1;
			if(stop == 1)statuLabel.setText("��ͣ��");
			else statuLabel.setText("��Ϸ��");
		}
		
		if(e.getKeyCode() == KeyEvent.VK_F2) {
			reStart();
		}
		
		if(GridPanel.lock)return;		//һ��ˢ�¼��ֻ�ܲ���һ����Ч�ķ����
		
		if(e.getKeyCode() == KeyEvent.VK_UP) {		
			if(Snake.length > 1 && Snake.head.dir == Direction.DOWN)return;	
			Snake.head.dir = Direction.UP;
			GridPanel.lock = true;
		}
		
		else if(e.getKeyCode() == KeyEvent.VK_DOWN) {
			if(Snake.length > 1 && Snake.head.dir == Direction.UP)return;
			Snake.head.dir = Direction.DOWN;
			GridPanel.lock = true;
		}
		
		else if(e.getKeyCode() == KeyEvent.VK_LEFT) {
			if(Snake.length > 1 && Snake.head.dir == Direction.RIGHT)return;
			Snake.head.dir = Direction.LEFT;
			GridPanel.lock = true;
		}
		
		else if(e.getKeyCode() == KeyEvent.VK_RIGHT) {
			if(Snake.length > 1 && Snake.head.dir == Direction.LEFT)return;
			Snake.head.dir = Direction.RIGHT;
			GridPanel.lock = true;
		}
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
