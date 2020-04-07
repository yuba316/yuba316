package game;

import java.awt.Color;
import java.awt.Graphics;

import javax.swing.JPanel;

public class GridPanel extends JPanel{		//��Ϸ������
	
	private static final long serialVersionUID = 1L;
	int x = 56;
	int y = 70;
	int width = 320;
	int height = 320;
	int gridHeight = height / Grid.HEIGHT;
	int gridWidth = width / Grid.WIDHT;
	static boolean lock;		//������
	static PaintThread thread ;	//��Ϸ����߳�
	
	GridPanel(){
		this.setBounds(x, y, width + gridWidth, height + gridHeight);
		this.setLayout(null);
		this.setVisible(true);
		thread = new PaintThread();
		thread.start();
	}
	
	public void paint(Graphics g) {		//��дpaint����
		super.paint(g);
		
		g.setColor(Color.BLACK);	//������
		for(int i = 0; i < Grid.WIDHT + 1; i++) {
			g.drawLine(0, i * gridWidth, height, i * gridWidth);
		}
		for(int i = 0; i < Grid.HEIGHT + 1; i++) {
			g.drawLine(i * gridHeight, 0, i * gridHeight, width);
		}
		
		g.setColor(Color.BLACK);	//�߽��Ϊ����
		for(SnakeNode node = Snake.head ; node != null; node = node.next) {
			int x = node.x;
			int y = node.y;
			g.fillRect(x * gridWidth, y * gridHeight, gridWidth, gridHeight );
			//System.out.println(x * gridWidth+" "+y * gridHeight+" "+(x+1) * gridWidth+" "+(y+1) * gridHeight );
		}
		
		g.setColor(Color.CYAN);		//ʳ��ΪԲ��
		int x = Food.food.getx();
		int y = Food.food.gety();
		g.fillOval(x * gridWidth, y * gridHeight, gridWidth, gridHeight);
	}
	
	class PaintThread extends Thread{		//�����߳�
		@Override
		public void run() {
		// TODO Auto-generated method stub
			Snake snake = new Snake();
			Food.food.setFood();
			lock = false;
			while(true){
				if(MainFrame.stop == 0)snake.move();
				repaint();
				try {
					lock = false;
					Thread.sleep(100);		//ˢ�¼��Ϊ100ms
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
	}
}
