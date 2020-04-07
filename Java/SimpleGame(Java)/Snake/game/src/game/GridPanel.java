package game;

import java.awt.Color;
import java.awt.Graphics;

import javax.swing.JPanel;

public class GridPanel extends JPanel{		//游戏面板界面
	
	private static final long serialVersionUID = 1L;
	int x = 56;
	int y = 70;
	int width = 320;
	int height = 320;
	int gridHeight = height / Grid.HEIGHT;
	int gridWidth = width / Grid.WIDHT;
	static boolean lock;		//操作锁
	static PaintThread thread ;	//游戏面板线程
	
	GridPanel(){
		this.setBounds(x, y, width + gridWidth, height + gridHeight);
		this.setLayout(null);
		this.setVisible(true);
		thread = new PaintThread();
		thread.start();
	}
	
	public void paint(Graphics g) {		//重写paint方法
		super.paint(g);
		
		g.setColor(Color.BLACK);	//画网格
		for(int i = 0; i < Grid.WIDHT + 1; i++) {
			g.drawLine(0, i * gridWidth, height, i * gridWidth);
		}
		for(int i = 0; i < Grid.HEIGHT + 1; i++) {
			g.drawLine(i * gridHeight, 0, i * gridHeight, width);
		}
		
		g.setColor(Color.BLACK);	//蛇结点为矩形
		for(SnakeNode node = Snake.head ; node != null; node = node.next) {
			int x = node.x;
			int y = node.y;
			g.fillRect(x * gridWidth, y * gridHeight, gridWidth, gridHeight );
			//System.out.println(x * gridWidth+" "+y * gridHeight+" "+(x+1) * gridWidth+" "+(y+1) * gridHeight );
		}
		
		g.setColor(Color.CYAN);		//食物为圆形
		int x = Food.food.getx();
		int y = Food.food.gety();
		g.fillOval(x * gridWidth, y * gridHeight, gridWidth, gridHeight);
	}
	
	class PaintThread extends Thread{		//绘制线程
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
					Thread.sleep(100);		//刷新间隔为100ms
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
	}
}
