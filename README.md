# xiaoyudi
Our current tech stack is as fllows:

![image](https://github.com/xiaoyudi-China/xiaoyudi_iOS/blob/master/tech_stack.png)

IOS client using Objective-C or swift as the development language, Xcode as an integrated development environment. Animation using CoreAnimation technology, data caching technology using CoreData, data embedding, tracking technology using RunTime, GrowingIO, audio and video playback technology using AVFoundation, network requests using AFNetworking, messaging based on Notification, We're using XMPP for instant messaging, Foundation, UIKit for basic framework, GCD, NSThread, NSOperation for multithreading. As mentioned in the IOS client, please refer to the official website of Apple Developers for the technology that has not been labeled separately.

The backend uses Java as the development language, nginx as the web server, tomcat7 as the web container, and the backend service to respond to api requests from the client.Back-end programs mainly use the following technical points:

The Spring framework is designed to ease the difficulty of Java development by using loosely coupled control inversion (IOC) support for aspect-oriented programming (AOP). Where SpringMVC is a very good model-view-controller (MVC) web framework that separates the different aspects of the application (input logic, business logic, and UI logic) while providing loose coupling between these elements. 
Hibernate is an open-source object-relational mapping (ORM) framework, which can establish a mapping between POJO and database tables to facilitate java programmers operating object-oriented programming database. 
MySQL is an open source relational database management system for storing business data. 
Maven is a project management tool that manages the building, reporting and documentation of Java projects through the Project Object Model (POM). 
Memcached serves as a high-performance, distributed memory object management system for reducing the load on MySQL databases. 
Redis and Memcached are similar, but it supports storing more value types and data structures, but also supports data persistence, Memcached make up for the deficiencies.
Netty is an excellent Java NIO network communication framework for asynchronous, high-performance, high-reliability network communications.

其他技术

1、语音识别技术（Speech Recognition）采用了科大讯飞，科大讯飞占有中文语音技术市场60%以上的市场份额。

2、语音合成技术（Speech Synthesis）使用了开源的 Ekho TTS, 支持普通话和多种中国方言。

3、自然语言处理技术采用了哈工大LTP及语言云，该技术针对非盈利项目开放了源码。
