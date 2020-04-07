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
	 * ����ʵ��������Ϸ�����ĳ�ʼ��
	 */
	private static final long serialVersionUID = -964036654185127258L; // �Ҳ�֪������Ǹ���ģ���ֻ�Ǹ���java����ʾ�����������
	public static int num_enemy=3; // ��һ�ص���ֻ��3��������Barrier�������ɵ��˵ĳ�����
	public static int power=2; // ��һ��ը������ֻ��2������Bomb����ȷ��ը����ը��Ļ���Ч��Χ
	public static boolean gg=true; // �ж���Ϸ�Ƿ�gg(�������trueΪ��δ����)
	public static ArrayList<Enemy> EnemyList; // ���ɵ����б�
	JDialog win; // ������Ӯ����
	JDialog lose;
	
	public WinOrLose(){
		this.setFocusable(true);
		EnemyList=new ArrayList<Enemy>();
		createenemy(); // ���ɵ���
		Thread plane1=new Thread(this);
		plane1.start();	
	}
	
	// ���ɵ���:
	public static void createenemy(){
		for(int i=0;i<20;i++){
			for(int j=0;j<20;j++){
				if(Barrier.place[i][j]==4){ // ��ͼ��Ϊ4������Ϊ���˵ĳ����أ����Barrier��
				Enemy ene=new Enemy(i*6, j*6); // ����Ϊ������6��
				Thread ene1=new Thread(ene);
				Barrier.place[i][j]=0; // �����˳���������Ϊ�յ�
				ene1.start();
				EnemyList.add(ene); // �������˵��б���ȥ
				}
			}
		}
	}
	
	public void paint(Graphics enemy){
		super.paint(enemy);
		Image Enemies=getToolkit().getImage("enemy.png"); 
		for(int i=0;i<EnemyList.size();i++){
			if(EnemyList.get(i).alive==true){ // �жϵ��������������Ƶ��˻���
				enemy.drawImage(Enemies, EnemyList.get(i).gety()*5, EnemyList.get(i).getx()*5, 30, 30, null);
			}else{
				EnemyList.remove(i); // �������˴��б����Ƴ�
			}
		}
		// ������ײ���:
		for(int i=0;i<EnemyList.size();i++){
			if(EnemyList.get(i).getEnemy().intersects(Character.crashenemy())){
				Character.death=true; // ���ײ�����ˣ�����������
			}
		}
	}
	
	// ���ж��߳�:
	// �ο���https://www.cnblogs.com/riskyer/p/3263032.html. ����԰. you Richer. Java�߳����.
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
			if(gg==true){ // �����Ϸ���ڽ���
				repaint();
				if(EnemyList.size()==0){ // ɱ�������ʤ��
					win(); // ����ʤ�����ڣ��ɽ�����һ��
					gg=false; // �ж���Ϸ
				}
				if(Character.death==true){ // ����������ʧ��
					Bomb.bombexist=false; // ը�����
					Bomb.timecount=0; // ��ʱ����
					lose(); // ����ʧ�ܴ���
					gg=false; // �ж���Ϸ
				}
			}	
		}
	}
	
	// ʤ������:
	private void win() {
		win = new JDialog();
		win.setSize(516, 246);
		win.setLocationRelativeTo(null);
		win.setLayout(null);
		JLabel info = new JLabel(new ImageIcon("win.jpg"));
		info.setBounds(0, 0, 501, 176);
		JLabel gameinfo = new JLabel("score��"+Bomb.score);
		gameinfo.setBounds(90, 176, 100, 30);
		JButton butun1=new JButton("next"); // ������һ��
		butun1.setBounds(0, 176, 90, 30);
		butun1.addActionListener(this);
		win.add(butun1);
		win.add(info);
		win.add(gameinfo);
		win.setVisible(true);
	}
	
	// ʧ�ܴ���:
	private void lose() {
		lose = new JDialog();
		lose.setSize(480, 300);
		lose.setLocationRelativeTo(null);
		lose.setLayout(null);
		JLabel info2 = new JLabel(new ImageIcon("lose.jpg"));
		info2.setBounds(0, 0, 465, 230);
		JLabel gameinfo2 = new JLabel("score��"+Bomb.score);
		gameinfo2.setBounds(100, 230, 90, 30);
		lose.add(info2);
		lose.add(gameinfo2);
		JButton butun2=new JButton("again");
		butun2.setBounds(0, 230, 90, 30);
		butun2.addActionListener(this);
		lose.add(butun2);
		lose.setVisible(true);
	}
	
	// �����:
	@Override
	public void actionPerformed(ActionEvent e) {
		// TODO Auto-generated method stub
		if(e.getActionCommand().equals("again")){
			Framework.creategame(); // ���³�ʼ����Ϸ
			lose.dispose(); // ������ʧ
		}
		if(e.getActionCommand().equals("next")){
			num_enemy=num_enemy+2; // ��һ�ص�����Ŀ��2
			power=power+1; // ͨ�غ�ը��������1���ɴݻ�ǽ�ڣ����Barrier��
			Framework.creategame(); // ���³�ʼ����Ϸ
			win.dispose(); // ������ʧ
		}
	}
}
