package game;

public class Food {
	
	private int x;
	private int y;
	public static Food food = new Food();
	
	void setFood() {
		while(true) {
			int x = (int)(Math.random()*16);
			int y = (int)(Math.random()*16);
			if(Grid.grid[x][y].isEmpty()) {
				Grid.grid[x][y].set(false,true);
				this.x = x;
				this.y = y;
				return;
			}
		}
	}
	
	int getx() {return x;}
	int gety() {return y;}
}
