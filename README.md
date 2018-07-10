# KinemAR
**Augmented Reality applied in movie posters**

This repository refers to the final project of the course: **Software Engineering Laboratory**, PESC / COPPE / UFRJ COS606, offered in partnership with the Virtual Reality Laboratory of COPPE ([Lab3D](http://lab3d.coppe.ufrj.br/)), taught by Professors [Cláudia Werner](https://www.cos.ufrj.br/~werner/) and [Claudia Susie Rodrigues](http://lattes.cnpq.br/5955317493247710) during the first semester of 2018.

**Students:**

* [Anna Gabrielle L P Homem](https://github.com/AnnaGabrielle)
* [Matheus Lemos](https://github.com/Lemos-san)
* [Rafael G Damasceno](https://github.com/DamascenoRafael)
* [Rodrigo C R de Jesus](https://github.com/rodrigoj42)


## About

The purpose of this repository is to demonstrate the use of augmented reality using as the main element the movie posters displayed in theaters. The goal is to recognize movie posters and present relevant information such as the movie trailer, where to buy tickets, synopsis, director, actors and ratings from different sources like: [IMDb](https://www.imdb.com/), [Metacritic](http://www.metacritic.com/) and [RottenTomatoes](https://www.rottentomatoes.com/). The application developed for iOS uses the [ARKit 2.0](https://developer.apple.com/arkit/) Framework and seeks to create a unique experience using the techniques and structures developed during the course.

This application makes use of a data scraper, developed for this project, which captures the information and posters of the available "now playing" and "comming soon" movies. This data scraper is available at: **[rodrigoj42/kinemar-scrapping](https://github.com/rodrigoj42/kinemar-scrapping)**.

## Installation


**Requirements**

* Xcode 10
* iOS 12.0+

**CocoaPods**

The project uses [CocoaPods](https://cocoapods.org/) as the dependency manager. If you do not have it installed, open the terminal and execute:

```
sudo gem install cocoapods
```

To install the dependencies, go to the project folder and run:

```
pod install
```

The project should always be opened through the **`kinemAR.xcworkspace`** file.