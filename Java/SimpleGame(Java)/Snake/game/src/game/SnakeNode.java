package game;

public class SnakeNode {	//ÿ����㱣�����ꡢ����ǰ���ͺ�̽�㣬���һ��˫������
	
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
