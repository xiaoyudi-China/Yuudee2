# Yuudee2

## Project Goals & Backgroud

![image](https://github.com/xiaoyudi-China/xiaoyudi_iOS/blob/master/launch/Beijing_Dakoudai.png)

You may have friends that you play with who are having a hard time expressing themselves verbally, or who find it challenging to bring words together to form a sentence. Unfortunately, there are limited solutions and tools out there to help children who have speech and language difficulties. Beijing Daokoudai’s Yuudee2 is an application aimed to address just that. It is designed to encourage children with difficulties in speech, or language expression to interact on various designed digital scenarios in order to practice completing sentences and help guide them in building words together with ease.

Yuudee 2 project is to create an augmented auxiliary communication App. It help students with language development retard on sentence structure(syntax) acquisition through intuitive, step- by-step and personalized approach. From simple sentences to compound sentences, this system present the children tasks with increasing difficulty level. By combining scenes and images with specific sentence structures, the system interacts with the children through questions and answers. Then students will be tested through the VB – MAPP. When the children’s language structure capability reaches the highest of Level 3, the system believes that they have acquired the usage of basic sentence structures. Then, individualized functions of this system enable the children to generalize the sentence structures they acquired in those scenarios, assists them to express their experience in complete sentences ，making it possible for them to use the sentence structures in their daily life.

## Directory Structure

* The main code in the iosapp directory;
* 3rd_party directory is the use of third-party libraries;
* Resources directory contains the main picture resources, cards directory includes various digital scenarios;
* Utils directory is a number of tools. 

## How to contribute to Yuudee2?

Make sure you read [Contributing.md](https://github.com/xiaoyudi-China/xiaoyudi_iOS/blob/master/CONTRIBUTING.md) when you start working on this project. 

## Tech Stack

Our current tech stack is as fllows:

![image](https://github.com/xiaoyudi-China/xiaoyudi_iOS/blob/master/images/tech_stack.png)

* IOS client using Objective-C or swift as the development language, Xcode as an integrated development environment. Animation using CoreAnimation technology, data caching technology using CoreData, data embedding, tracking technology using RunTime, GrowingIO, audio and video playback technology using AVFoundation, network requests using AFNetworking, messaging based on Notification, We're using XMPP for instant messaging, Foundation, UIKit for basic framework, GCD, NSThread, NSOperation for multithreading. As mentioned in the IOS client, please refer to the official website of Apple Developers for the technology that has not been labeled separately.

* The backend uses Java as the development language, nginx as the web server, tomcat7 as the web container, and the backend service to respond to api requests from the client. Back-end programs mainly use the following technical points:

* The Spring framework is designed to ease the difficulty of Java development by using loosely coupled control inversion (IOC) support for aspect-oriented programming (AOP). Where SpringMVC is a very good model-view-controller (MVC) web framework that separates the different aspects of the application (input logic, business logic, and UI logic) while providing loose coupling between these elements. 
Hibernate is an open-source object-relational mapping (ORM) framework, which can establish a mapping between POJO and database tables to facilitate java programmers operating object-oriented programming database. 
* MySQL is an open source relational database management system for storing business data. 
* Maven is a project management tool that manages the building, reporting and documentation of Java projects through the Project Object Model (POM). 
* Memcached serves as a high-performance, distributed memory object management system for reducing the load on MySQL databases. 
* Redis and Memcached are similar, but it supports storing more value types and data structures, but also supports data persistence, Memcached make up for the deficiencies.
* Netty is an excellent Java NIO network communication framework for asynchronous, high-performance, high-reliability network communications.

### Other technologies
* Speech Recognition (Speech Recognition) Itexamotech, Itexamote to occupy Chinese voice technology market more than 60% market share.
* Speech Synthesis uses the open source Ekho TTS, which supports Mandarin and a variety of Chinese dialects.
* Natural language processing technology used HIT LTP and language cloud, the technology for non-profit projects open source.

## Lincese

[GNU General Public License v3.0](https://github.com/xiaoyudi-China/xiaoyudi_iOS/blob/master/LICENSE)

## Others

UNICEF Innovation Fund: [Beijing Daokoudai](http://unicefstories.org/2017/12/07/beijingdaokoudai/)
