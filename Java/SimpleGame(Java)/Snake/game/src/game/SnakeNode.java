package game;

public class SnakeNode {	//每个结点保存坐标、方向、前驱和后继结点，组成一个双向链表
	
	int x,y;
	int dir;
	
	SnakeNode next;
	SnakeNode pre;
	
	public SnakeNode(int x,int y,int dir) {
		this.x = x;
		this.y = y;
		this.dir = dir;
	}
}
