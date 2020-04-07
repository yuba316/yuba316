package game;

public class Snake {      //贪吃蛇是由SnakeNode结点组成的双向链表
	
	static SnakeNode head;	//链表头、尾结点、长度
	static SnakeNode tail;
	static int length;		
	
	public Snake() {	//初始化
		SnakeNode node = new SnakeNode(5,5,Direction.RIGHT);	
		head = node;
		tail = node;
		length = 1;
	}
	
	public void move() {	//移动
		int dir = head.dir;		//移动方向为头朝向的方向
		int x = head.x + Direction.moveValue[dir][0];
		int y = head.y + Direction.moveValue[dir][1];
		
		if(x < 0 || x >= Grid.WIDHT || y < 0 || y >= Grid.HEIGHT || Grid.grid[x][y].isSnake()) {
			MainFrame.mainFrame.gameOver();		//碰撞检测
			return;
		}
		if(Grid.grid[x][y].isFood()) {		//吃到食物，链表长度+1
			length++;
			MainFrame.scoreLabel.setText("当前分数:" + (length-1));
			 
			Grid.grid[x][y].set(true,false);	//食物所在格变为蛇头
		
			SnakeNode node = new SnakeNode(x,y,dir);
			head.pre = node;	//把新头结点加到原头结点前面
			node.next = head;
			head = node;

			Food.food.setFood();	//设置新的食物
			
			return;
		}
		//没有吃到食物，头尾结点均向前移动一格，将原尾结点删除，增加新的头结点
		Grid.grid[tail.x][tail.y].clear();	
		Grid.grid[x][y].set(true,false);

		if(head.next == null) {		//只有1个结点，即蛇长度为1
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
