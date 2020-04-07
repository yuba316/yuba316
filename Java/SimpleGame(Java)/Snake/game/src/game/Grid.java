package game;

public class Grid {		//������Ϣ
	static final int WIDHT = 16;	
	static final int HEIGHT = 16;
	private boolean snake;		//�Ƿ�Snakeռ��
	private boolean food;		//�Ƿ�foodռ��
	public static Grid[][] grid = new Grid[WIDHT+1][HEIGHT+1];	//Grid[x][y]��������(x,y)��������Ϣ
	
	void clear() {
		this.snake = false;
		this.food = false;
	}
	
	void set(boolean s,boolean f) {
		this.snake = s;
		this.food = f;
	}
	
	boolean isFood() {
		return food;
	}
	
	boolean isSnake() {
		return snake;
	}
	
	boolean isEmpty() {
		return !(food | snake);
	}
}
