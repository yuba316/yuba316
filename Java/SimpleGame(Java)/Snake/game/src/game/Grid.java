package game;

public class Grid {		//网格信息
	static final int WIDHT = 16;	
	static final int HEIGHT = 16;
	private boolean snake;		//是否被Snake占用
	private boolean food;		//是否被food占用
	public static Grid[][] grid = new Grid[WIDHT+1][HEIGHT+1];	//Grid[x][y]保存坐标(x,y)的网格信息
	
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
