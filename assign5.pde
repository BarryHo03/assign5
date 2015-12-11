PImage bg1, bg2, end1, end2, enemy, fighter, hp, start1, start2, treasure,shoot;
float background1X,background2X,e,blood,fighterX,fighterY,treasureX,treasureY;
float speedF=5;
PImage explodeFlames[]= new PImage[5];
boolean upPressed = false;
boolean downPressed = false;
boolean leftPressed = false;
boolean rightPressed = false;
final int GAME_START = 0;
final int GAME_RUN= 1;
final int GAME_OVER= 2;
final int enemyCount=8;
float []enemyX=new float[enemyCount];
float[]enemyY=new float [enemyCount];
float []flameX=new float[enemyCount];
float []flameY=new float[enemyCount];
float []shootX=new float[5];
float []shootY=new float[5];
float []bulletY=new float[5];
boolean[]explode=new boolean[enemyCount];
float[] distance = new float[enemyCount];
int gameState = GAME_START;
int currentFrame;
int score=0;
int enemyWave, enemyXCount;
void setup () {
  size(640, 480) ;
  bg1=loadImage("img/bg1.png");
  bg2=loadImage("img/bg2.png");
  enemy=loadImage("img/enemy.png");
  fighter=loadImage("img/fighter.png");
  hp=loadImage("img/hp.png");
  treasure=loadImage("img/treasure.png");
  end1=loadImage("img/end1.png");
  end2=loadImage("img/end2.png");
  start1=loadImage("img/start1.png");
  start2=loadImage("img/start2.png");
  shoot=loadImage("img/shoot.png");
  e=random(0,height-enemy.height);
  treasureX=random(0,width-treasure.width);
  treasureY=random(0,height-treasure.height);
  background1X=640;
  background2X=0;
  blood=39;
  enemyXCount=-80;
  currentFrame=0;
  fighterX=width-fighter.width;
  fighterY=height/2 - fighter.height/2;
  for(int i =0;i<explodeFlames.length;i++){
    explodeFlames[i]=loadImage("img/flame"+(i+1)+".png");
  }
  for(int i =0;i<5; i++){
    bulletY[i]=0;
    shootX[i]  = -1;
    shootY[i]  = -1;
  }

  for(int i =0;i<8;i++){
    explode[i]=false;
  
  }
  addEnemy(enemyWave);
}

void draw() { 
  switch(gameState){
    case GAME_START:
      image(start2,0,0);
      if(mouseY >370 && mouseY<420 && mouseX>210 && mouseX<450){
        image(start1,0,0);
        if(mousePressed){
          gameState=GAME_RUN;
        }
      }
    break;
    case GAME_OVER:
    image(end2,0,0);
    if(mouseY >310 && mouseY<350 && mouseX>200 && mouseX<440){
        if(mousePressed){
          gameState=GAME_RUN;
          blood=39;
          e=random(0,height-enemy.height);
          fighterX=width-fighter.width;
          fighterY=height/2-fighter.height;
          for(int i=0;i<8;i++){
            explode[i]=false;
          }
          for(int i=0;i<5;i++){
            score=0;
            bulletY[i]=0;
          }
        }else{
        image(end1,0,0);
        }
    }
    break;
    case GAME_RUN:
    //bg
    showBackground();
    //hp 
    showHp();
    //explosion
    showExplosion();
         
    //enemy & its movement
    enemyXCount+=5;
    for(int i = 0; i < enemyCount; ++i){
        if(enemyX[i]!= -1||enemyY[i]!= -1){
          image(enemy, enemyX[i], enemyY[i]);
          enemyX[i]+=5;
          if(enemyX[i]>640){
            enemyX[i]=-1;
            enemyY[i]=-1;
          }
        }
      }
    if(enemyXCount > 1000){
      enemyXCount = -80;
      enemyWave++;
      enemyWave %= 3;
      addEnemy(enemyWave);
     }
    //collision
    for(int i=0;i<8;i++){  
      if(enemyX[i] != -1 || enemyY[i] !=-1){
      if(isHit(enemyX[i],enemyY[i],enemy.width,enemy.height,fighterX,fighterY,fighter.width,fighter.height)){
        currentFrame=0;
        explode[i]=true;
        flameX[i]=enemyX[i];
        flameY[i]=enemyY[i];
        enemyX[i]=-100;
        enemyY[i]=-100;
        blood-=39;    
      }
      }            
    }
     
    shootBullet();
    //missile
    int [] Num = new int[enemyCount];
    for(int i=0; i<5; i++){
      if(shootX[i]!=-1||shootY[i]!=-1){
        Num[i] = closestEnemy(shootX[i],shootY[i]);
      if(Num[i]!= -1){
        if(shootY[i]<enemyY[Num[i]]){
          shootY[i]+= 1;
        }else if(enemyY[Num[i]] < shootY[i]){
          shootY[i]-= 1;
         }
        }
      }
    }

        
    //fighter&shoot
    for(int i=0;i<5;i++){
      //missile 
      for(int k=0; k<8; k++){
      
    // bullet hit detection
    if(shootX[i] != -1 || shootY[i] != -1){
      if(enemyX[k] != -1 || enemyY[k] !=-1){
        if(isHit(enemyX[k],enemyY[k],enemy.width,enemy.height,shootX[i],shootY[i],shoot.width,shoot.height)){
          shootX[i] = shootY[i] = -1;
          currentFrame=0;
          explode[k]=true;
          flameX[k]=enemyX[k];
          flameY[k]=enemyY[k];
          enemyX[k]=1000;
          enemyY[k]=1000;
          scoreChange(20);
          bulletY[i]=0;
        }   
       }
      }
     } 
    }
    
    
    //treasure
    image(treasure,treasureX,treasureY); 
    
    //refill hp
    if(isHit(treasureX,treasureY,treasure.width,treasure.height,fighterX,fighterY,fighter.width,fighter.height)){
      blood+=19.5;
      treasureX=random(0,width-treasure.width);
      treasureY=random(0,height-treasure.height);
    }
    if(blood>195){
      blood=195;
    }
      
    fighterControl();
    
    showScore();
    
    if(blood<=0){
    gameState=GAME_OVER;
    
    }
    break;   
  }  
}
void shootBullet(){
  for(int i=0; i<5; i++){
    if(shootX[i] != -1 || shootY[i] != -1){
      image(shoot, shootX[i], shootY[i]);
      shootX[i]-=6;
    }
    if(shootX[i] <= -31)
      shootX[i] = shootY[i] = -1;
    }
}

void keyPressed(){
  if(key == ' ' ){
    for(int i = 0; i < 5;i++){
      if(shootY[i] == -1){
        shootX[i] = fighterX;
        shootY[i] = fighterY+fighter.height/2-shoot.height/2;
        break;
      }
    } 
  }   
  if(key == CODED){
    switch(keyCode){
      case UP:
        upPressed = true;
        break;
      case DOWN:
        downPressed = true;
        break;
      case LEFT:
        leftPressed = true;
        break;
      case RIGHT:
        rightPressed = true;
        break;
    }      
  }
}
void keyReleased(){ 
  if (key == CODED) {    
    switch (keyCode) {
      case UP:
        upPressed = false;
        break;
      case DOWN:
        downPressed = false;
        break;
      case LEFT:
        leftPressed = false;
        break;
      case RIGHT:
        rightPressed = false;
        break;
    }
  }
}
void fighterControl(){
  image(fighter,fighterX,fighterY);
    if(upPressed){
      fighterY-=speedF;
     }
    if(downPressed){
      fighterY+=speedF;
    }
    if(rightPressed){
      fighterX+=speedF;
    }
    if(leftPressed){
      fighterX-=speedF;
    }
    if(fighterX>width-fighter.width){
    fighterX=width-fighter.width;
    }
    if(fighterX<0){
    fighterX=0;
    }
    if(fighterY>height-fighter.height){
    fighterY=height-fighter.height;
    }
    if(fighterY<0){
    fighterY=0;
    } 
}

void showScore(){
  textAlign(LEFT,BOTTOM);
  textSize(26);
  fill(255);
  text("Score:"+score,0,height);
}

void scoreChange(int value){
score+=value;
}


boolean isHit(float ax, float ay, float aw, float ah, float bx, float by, float bw, float bh){
  if(bx<=ax+aw && bx>=ax-bw && by>=ay-bh && by<=ay+ah){
    return true;
  }else{
    return false;
  }
} 

int closestEnemy(float x, float y){
 int index = -1;
 for (int i = 0; i < enemyCount;i++){
   if(x > enemyX[i]){
   if(enemyX[i] != -1 || enemyY[i] != -1){
         distance[i] = dist(x,y,enemyX[i],enemyY[i]);
         float min = distance[i];
         index = i;
         for(int j = i+1; j < enemyCount ; j++){
           distance[j] = dist(x,y,enemyX[j],enemyY[j]);
           if(min>distance[j]){
             min = distance[j];
             index = j;
           }
         }
         break;
       }
    }
 }
  if (index == -1){
    return -1;
  }
  else{
    return index;
  }
}


void showBackground(){
  image(bg1,background1X-640,0);
  background1X++;
  background1X%=1280;
    
  image(bg2,background2X-640,0);
  background2X++;
  background2X%=1280;  
}

void showHp(){
   noStroke();
   fill(255,0,0);
   rect(10,0,blood,20);
   image(hp,0,0);
}

void showExplosion(){
  int j = currentFrame ++;
  for(int i=0;i<8;i++){
    if(explode[i]){
      if(0<=j&&j<6){
        image(explodeFlames[0], flameX[i], flameY[i]);    
      }
      if(6<=j&&j<12){
        image(explodeFlames[1], flameX[i], flameY[i]);    
      }
      if(12<=j&&j<18){
        image(explodeFlames[2], flameX[i], flameY[i]);    
      }
      if(18<=j&&j<24){
        image(explodeFlames[3], flameX[i], flameY[i]);    
      }
      if(24<=j&&j<30){
        image(explodeFlames[4], flameX[i], flameY[i]);    
      }
      if(j>=30){
        explode[i]=false;
      }
    }    
  }
}

void addEnemy(int type)
{  
  for (int i = 0; i < enemyCount; ++i) {
    enemyX[i] = -1;
    enemyY[i] = -1;
  }
  switch (type) {
    case 0:
      addStraightEnemy();
      break;
    case 1:
      addSlopeEnemy();
      break;
    case 2:
      addDiamondEnemy();
      break;
  }
}

void addStraightEnemy()
{
  float t = random(height - enemy.height);
  int h = int(t);
  for (int i = 0; i < 5; ++i) {

    enemyX[i] = (i+1)*-80;
    enemyY[i] = h;
  }
}
void addSlopeEnemy()
{
  float t = random(height - enemy.height * 5);
  int h = int(t);
  for (int i = 0; i < 5; ++i) {

    enemyX[i] = (i+1)*-80;
    enemyY[i] = h + i * 40;
  }
}
void addDiamondEnemy()
{
  float t = random( enemy.height * 3 ,height - enemy.height * 3);
  int h = int(t);
  int x_axis = 1;
  for (int i = 0; i < 8; ++i) {
    if (i == 0 || i == 7) {
      enemyX[i] = x_axis*-80;
      enemyY[i] = h;
      x_axis++;
    }
    else if (i == 1 || i == 5){
      enemyX[i] = x_axis*-80;
      enemyY[i] = h + 1 * 40;
      enemyX[i+1] = x_axis*-80;
      enemyY[i+1] = h - 1 * 40;
      i++;
      x_axis++;      
    }
    else {
      enemyX[i] = x_axis*-80;
      enemyY[i] = h + 2 * 40;
      enemyX[i+1] = x_axis*-80;
      enemyY[i+1] = h - 2 * 40;
      i++;
      x_axis++;
    }
  }
}
