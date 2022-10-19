from icrawler.builtin import GoogleImageCrawler
import os, cv2 as cv
from concurrent import futures

WIDTH = 216
HEIGHT = 384

def collectImage(keyword, num = 2000):
  imageDir = f'./images/{keyword}'
  google_crawler = GoogleImageCrawler(storage={'root_dir': imageDir})
  google_crawler.crawl(keyword=keyword, max_num=num)
  
  fileList = os.listdir(imageDir)
  fileList = [f for f in fileList if os.path.isfile(os.path.join(imageDir, f))]
  for f in fileList:
    os.makedirs("./image", exist_ok=True)
    writePath = os.path.join("./image/",  os.path.splitext(os.path.basename(f))[0])
    image = cv.imread(os.path.join(imageDir, f), cv.IMREAD_COLOR)
    width = image.shape[1]
    height = image.shape[0]
    resizeRatio = max(WIDTH / width, HEIGHT / height)
    image = cv.resize(image,dsize=None, fx=resizeRatio, fy=resizeRatio)
    
    # Crop image
    width = image.shape[1]
    height = image.shape[0]
    center = [int(width / 2), int(height / 2)]
    left = center[0] - int(WIDTH / 2)
    right = center[0] + int(WIDTH / 2)
    top = center[1] - int(HEIGHT / 2)
    bottom = center[1] + int(HEIGHT / 2)
    
    croped = image[top:bottom, left:right]
    
    cv.imwrite(f"{writePath}.png", croped)
  
def main():
  with open("./searchWord.txt", encoding="utf-8") as f:
    wordList = f.readlines()
    
    with futures.ProcessPoolExecutor(max_workers=24) as executor:
      futureList = []
      for word in wordList:
        future = executor.submit(collectImage, word.rstrip('\n'))
        futureList.append(future)
      
      _ = futures.as_completed(futureList)
    
if __name__ == "__main__":
  main()
