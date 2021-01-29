//ihtiyacımız olan kütüphaneleri import ediyoruz //<>//
//sound => mikrofon için,
//video => kamera için
import processing.sound.*;
import processing.video.*;

//kamera objemiz
Capture cam;

//mikrofon objemiz
AudioIn mik;

//mikrofondan gelen ses seviyeleri için gerekli olan objemiz
Amplitude analyzer;

//renkler adında bir array oluşturuyoruz
//bu arrayimiz 3 tane color objesi barındırıyor
//1. obje => kırmızı
//2. obje => yeşil
//3. obje => mavi
color[] renkler = {color(255, 0, 0), color(0, 255, 0), color(0, 0, 255)};

//kamera görüntümüzün pixel işlemlerini yapabilmek için kullanacağımız döngülerimizin satır ve sütun değerleri
int sutun, satir;

//parlaklığa göre çizeceğimiz halkaların yoğunluk sayısı
//sayı büyüdükçe halkalar büyür
int yogunluk = 10;

//mikrofondan gelen ses seviyesine göre çizeceğimiz çizgilerin kalınlık değeri
int kalinlik = 10;

void setup() {
  //1280x720 tablomuzu oluşturuyoruz
  size(1280, 720);

  //döngülerimizde kullanabilmek için satır ve sütun değerimizi tablomuzun boyutlarını yoğunluğa bölerek hesaplıyoruz
  sutun = width / yogunluk;
  satir = height / yogunluk;

  //bilgisayarımızdaki kamera cihazlarının listesini alıyoruz
  //birden fazla kameramız olabilir, kamera objemizi seçerken hangisini seçeceğimizi belirtiyoruz
  String[] camler = Capture.list();

  //cam objemizi processing.video kütüphanemizden, yukarıda hesapladığımız satır-sütun ölçülerinde ve camler listemizin en başındaki kamera ismimiz ile oluşturuyoruz
  //kamera objesini oluştururken kamera cihazının ismini vermemiz gerekiyor ki hangi cihazdan görüntü alacağını belirleyebilelim
  //kameralar[0] değeri bizim "camler" listemizin en başındaki değeri tutuyor yani bilgisayarın varsayılan kamerası
  //örn: "Logitech C920"
  cam = new Capture(this, sutun, satir, camler[0]);
  cam.start();

  //bilgisayarımızdaki mikrofonlar arasından en üstteki mikrofonu seçiyoruz
  mik = new AudioIn(this, 0);
  //mikrofondan dinleme işlemini başlatıyoruz
  mik.start();

  //ses seviyeleri için geçerli objemizi oluşturuyoruz
  analyzer = new Amplitude(this);
  //giriş cihazı olarak mikrofonumuzu belirtiyoruz
  analyzer.input(mik);
}

void draw() {
  //arkaplan renklendirmelerimizi yapıyoruz, üzerine görselimizin pixellerinin parlaklık değerlerine göre halkalar ekleyeceğiz
  background(#CAD3C8);
  noStroke();

  //eğer kameramız hazır ise kameradan görüntüyü alıyoruz
  if (cam.available())
    cam.read();

  //kamera dan get mothodu ile görüntü alıp img diye bir değerde tutuyoruz, bu değer üzerinden pixel işlemlerimizi gerçekleştireceğiz
  PImage img = cam.get();
  
  //img objemizi parlakligaGoreHalkalama fonksiyonumuza gönderip, gerekli işlemleri o fonksiyon içerisinde yapacağız
  parlakligaGoreHalkalama(img);

  //ekranda ses dalgalarını çizecek fonksiyonumuzu çağırarak çizme işlemini gerçekleştiriyoruz
  sesDalgalariniCiz();
}

//kameradan aldığımız görüntüyü işleyip, parlaklığa göre halkalama işlemi gerçekleştireceğimiz fonksiyonumuz
//içerisine gönderdiğimiz "img" parametresi kameradan aldığımız anlık görüntüyü içeriyor
//kameradan aldığımız görüntüyü yani img objesini fonksiyonda işleyip halkalarımızı yerleştireceğiz
//ayrı fonksiyonda yazmamızın sebebi, temiz, okunaklı ve tekrar kullanılabilir olması
void parlakligaGoreHalkalama(PImage img){
//görselin üzerindeki pixellerin renklerine ulaşabilmek için loadPixel() fonksiyonu ile img.pixels[] arrayini oluşturuyoruz
  img.loadPixels();

  //görüntüyü matrix olarak bölme yapıp, satır ve sütunlar üzerinden tek tek gezinerek işlem yapacağımız döngülerimiz
  //sütunda gezinme döngümüz
  for (int i = 0; i < sutun; i++) {
    //satırda gezinme döngümüz
    for (int j = 0; j < satir; j++) {
      //görüntünün simetrisini hesaplayıp hangi pixelde olduğumuzu tutacak değer (o pixelin konumunu gösteren değer)
      int konum = (img.width - i - 1) + j * img.width;

      //kamera görüntüsünün o konumdaki pixelinin renk değeri
      color c = img.pixels[konum];

      //yukarıda aldığımız pixelin renk değerinin parlaklığına göre parlak alanlara koyacağımız yuvarlağın yarı çapı
      //ne kadar parlak olursa o kadar büyük yuvarlak koyuyoruz
      //yogunluk değerimizi yukarıda 10 olarak belirlemiştik
      float r = (brightness(c)/255) * yogunluk;

      //koyacağımız halkanın merkez koordinatını yogunluk değerine göre hesaplıyoruz
      float sx = i * yogunluk;
      float sy = j * yogunluk;

      //halkanın renklendirmesini yapıyoruz (random olarak ürettiğimiz renkler ile)
      fill(random(210, 240), random(10, 30), random(0, 70), 83);

      //yukarıda hesapladığımız koordinatlar ve yarıçap değeri ile halkamızı yerleştiriyoruz
      circle(sx, sy, r);
    }
  }
}

//ses dalgalarını çizecek fonksiyonumuz
void sesDalgalariniCiz() {
  //mikrofondan aldığımız ses değerini analiz edip, "ses" objemizde tutuyoruz
  //yüksek sesle konuşulduğunda bu değer yüksek çıkıyor
  //değer aralığı 0-1 arası
  float ses = analyzer.analyze();

  //kamera görüntümüzü kullandığımız için çubuklarımıza herhangi bir renk doldurma işlemi yapmıyoruz
  noFill();

  //ekranda çizilen renkli çizgilerin kalınlıklarını ayarlıyoruz, yukarıda bu değeri 10 olarak belirlemiştik
  strokeWeight(kalinlik);

  //döngü ile renklendirme işlemimizi yapıyoruz
  //döngü 3 kere dönüyor, her bir turda renkler arrayimizin içerisinden
  //i(nci) rengi alıp stroke methodu ile boyama işlemini yapıyoruz
  for (int i = 0; i < 3; i++) {
    stroke(renkler[i]);

    //ekranda çizme işlemini gerçekleştirecek başlangıç methodumuz
    beginShape();
    //ses 0 ise mikrofondan hiç ses girişi yok,
    //ses 0.01'den büyükse ses girişi var
    //mikrofonun hassasiyet değeri olarak düşünülebilir
    //bu değere göre ekranda renkli çizgileri gösteriyoruz
    //hassasiyet değeri yükselirse ekranda renkli çizgilerin görünmesi için yüksek ses girişi olmalı
    if (ses > 0.01)
    {
      //ekrana çizilecek çizgilerin döngüsü
      //w değeri çizginin genişliğini,
      //h değeri çizginin kalınlığını gösteriyor
      //dalgalanmanın çizilimi için matematiksel fonksiyonlar kullanılıyor
      //bu fonksiyonlara ses değerimizi veriyoruz, böylelikle sese duyarlı olarak çizim yapılıyor
      for (int w = -20; w < width + 20; w += 15) {
        float h = height / 2;
        h += 200 * sin(w * 0.03 + ses * 10 + i * TWO_PI / 3) * pow(abs(sin(w * 0.001 + ses * 3)), 5);

        //çizgileri ekrana çizen metod
        curveVertex(w, h);
      }
    }

    //beginShape methodu ile başlattığımız çizimi endShape ile sonlandırıyoruz
    endShape();
  }
}
