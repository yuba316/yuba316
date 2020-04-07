package game;

public class Snake {      //̰��������SnakeNode�����ɵ�˫������
	
	static SnakeNode head;	//����ͷ��β��㡢����
	static SnakeNode tail;
	static int length;		
	
	public Snake() {	//��ʼ��
		SnakeNode node = new SnakeNode(5,5,Direction.RIGHT);	
		head = node;
		tail = node;
		length = 1;
	}
	
	public void move() {	//�ƶ�
		int dir = head.dir;		//�ƶ�����Ϊͷ����ķ���
		int x = head.x + Direction.moveValue[dir][0];
		int y = head.y + Direction.moveValue[dir][1];
		
		if(x < 0 || x >= Grid.WIDHT || y < 0 || y >= Grid.HEIGHT || Grid.grid[x][y].isSnake()) {
			MainFrame.mainFrame.gameOver();		//��ײ���
			return;
		}
		if(Grid.grid[x][y].isFood()) {		//�Ե�ʳ�������+1
			length++;
			MainFrame.scoreLabel.setText("��ǰ����:" + (length-1));
			 
			Grid.grid[x][y].set(true,false);	//ʳ�����ڸ��Ϊ��ͷ
		
			SnakeNode node = new SnakeNode(x,y,dir);
			head.pre = node;	//����ͷ���ӵ�ԭͷ���ǰ��
			node.next = head;
			head = node;

			Food.food.setFood();	//�����µ�ʳ��
			
			return;
		}
		//û�гԵ�ʳ�ͷβ������ǰ�ƶ�һ�񣬽�ԭβ���ɾ���������µ�ͷ���
		Grid.grid[tail.x][tail.y].clear();	
		Grid.grid[x][y].set(true,false);

		if(head.next == null) {		//ֻ��1����㣬���߳���Ϊ1
			head.x = x;
			head.y = y;
		}
		else {
			SnakeNode node = new SnakeNode(x,y,dir);
			head.pre = node;
			node.next = head;
			head = node;
			
			SnakeNode temp = tail;
			tail.pre.next = null;
			tail = temp.pre; 
			temp = null;
		}
	}
}
