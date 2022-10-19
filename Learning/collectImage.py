from icrawler.builtin import BingImageCrawler
import os, cv2 as cv
from concurrent import futures
from imgPreProcess import process

WIDTH = 216
HEIGHT = 384

def collectImage(keyword, num = 2000):
  imageDir = f'./image/{keyword}'
  crawler = BingImageCrawler(
    storage={'root_dir': imageDir}, 
    feeder_threads=1,
    parser_threads=1,
    downloader_threads=4,)
  crawler.crawl(keyword=keyword, max_num=num)
  
  #process(keyword)
  
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
