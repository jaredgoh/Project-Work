---
title: "Standard Rmd Note format"
author: "JD"
output:
  html_document:
    keep_md: yes
    theme: cerulean
    code_folding: show
    toc: true
    toc_depth: 4
---

<style type="text/css">
.main-container{
  max-width: 1300px;
  margin-left: auto;
  margin-right: auto;
}
body, td{
  font-family: Helvetica;
  font-size: 16pt;
}
pre{ 
  font-size: 14px; 
}
pre.r{ 
  font-size: 14px;
}
</style>



<br/>

**References**  

* https://github.com/yusuzech/r-web-scraping-cheat-sheet#rvest7.1  
* https://blog.rstudio.com/2014/11/24/rvest-easy-web-scraping-with-r/  
* https://stat4701.github.io/edav/2015/04/02/rvest_tutorial/  
* https://www.analyticsvidhya.com/blog/2017/03/beginners-guide-on-web-scraping-in-r-using-rvest-with-hands-on-knowledge/  
* https://rpubs.com/ryanthomas/webscraping-with-rvest  

***
<br />

## Web Scraping The Lego Movie

Web Scraping in R is essentially done with the package **rvest**. This guide will attempt to combine several other guides I have read into one. I also attempt to scrap serveral additional websites for practise.  
We start by downloading and parsing the file for the **Lego Movie** with `read_html()`


```r
# downloading and parsing the file using read_html
lego_movie <- read_html("http://www.imdb.com/title/tt1490017/")


# Alternatively you can download the file directly as a .html file 
#download.file("http://www.imdb.com/title/tt1490017/", 
#               destfile = "lego_movie.html", mode = "wb")
```

<br />

Opening the downloaded html file from my laptop, we see its an exact replica of the webpage.  
[Downloaded html file](lego_movie.html)    
What we now need is to somehow identify which section of the html page we need. This is done via an open source tool called selectorgadget.

<br />

<span style = "color:Maroon">***What is selectorgadget ?***</span>  
In a nutshell [selectorgadget](https://selectorgadget.com/) generates what is called a CSS selector that matches the html element that we want. We then use this generated CSS selector to obtain the data via the following functions:  


```r
# excracting movie rating
lego_movie %>%
  html_node("strong span") %>%
  html_text() %>%
  as.numeric()
```

```
## [1] 7.8
```

```r
# extracting movie summary 
lego_movie %>%
  html_node(".summary_text") %>%
  html_text()
```

```
## [1] "\n                    An ordinary LEGO construction worker, thought to be the prophesied as \"special\", is recruited to join a quest to stop an evil tyrant from gluing the LEGO universe into eternal stasis.\n            "
```

```r
# extracting the cast
lego_movie %>%
  html_nodes(".primary_photo+ td a") %>%
  html_text()
```

```
##  [1] " Will Arnett\n"     " Elizabeth Banks\n" " Craig Berry\n"    
##  [4] " Alison Brie\n"     " David Burrows\n"   " Anthony Daniels\n"
##  [7] " Charlie Day\n"     " Amanda Farinos\n"  " Keith Ferguson\n" 
## [10] " Will Ferrell\n"    " Will Forte\n"      " Dave Franco\n"    
## [13] " Morgan Freeman\n"  " Todd Hansen\n"     " Jonah Hill\n"
```

<br />

We use `html_node()` to find the first node that matches the selector, and extract its contents with `html_text()`. We can also use `html_nodes()` which finds all the nodes that match the selector:


```r
# extracting the movie reviews
lego_movie_reviews <- read_html("https://www.imdb.com/title/tt1490017/reviews?ref_=tt_urv")

# getting the all the nodes that match the "review" selector created
lego_movie_reviews %>%
  html_nodes(".text")
```

```
## {xml_nodeset (25)}
##  [1] <div class="text show-more__control">Like many of you, the first ti ...
##  [2] <div class="text show-more__control">The stand out feature of the L ...
##  [3] <div class="text show-more__control">Hollywood has a long history o ...
##  [4] <div class="text show-more__control">I'd be surprised if anyone saw ...
##  [5] <div class="text show-more__control">I was the only adult who didn' ...
##  [6] <div class="text show-more__control">If you watch the trailer and y ...
##  [7] <div class="text show-more__control">This is my first review. I nev ...
##  [8] <div class="text show-more__control">To be honest \u0096 when I fir ...
##  [9] <div class="text show-more__control">Went to see it with my brother ...
## [10] <div class="text show-more__control">I usually enjoy children's fil ...
## [11] <div class="text show-more__control">This film has great animation  ...
## [12] <div class="text show-more__control">I go to see this movie with ot ...
## [13] <div class="text show-more__control">In the Lego Movie, and evil mi ...
## [14] <div class="text show-more__control">I'm the only person I know tha ...
## [15] <div class="text show-more__control">"The Lego Movie" is irritating ...
## [16] <div class="text show-more__control">It was approaching the end of  ...
## [17] <div class="text show-more__control">my god this movie is amazing,  ...
## [18] <div class="text show-more__control">Cute movie. That's about it. A ...
## [19] <div class="text show-more__control">A fun film that made me a kid. ...
## [20] <div class="text show-more__control">I absolutely hated this movie. ...
## ...
```

<br />

As we can see from above, `html_nodes()` only returns the list of nodes that match the css selector used. We must then extract the information we want from the nodes using additional functions.  

Naturally we are not limited to just extracting text. Through some clever manipulation, we can scrape images easily as well.


```r
# identifies the url of the movie poster
poster <- lego_movie %>%
  html_nodes("#title-overview-widget img") %>%
  html_attr("src")
poster
```

```
## [1] "https://m.media-amazon.com/images/M/MV5BMTg4MDk1ODExN15BMl5BanBnXkFtZTgwNzIyNjg3MDE@._V1_UX182_CR0,0,182,268_AL_.jpg"                    
## [2] "https://m.media-amazon.com/images/M/MV5BMzkyMjA1ODQzMV5BMl5BanBnXkFtZTgwMTQ2NzMyMzE@._V1_CR167,0,946,532_AL_UY268_CR84,0,477,268_AL_.jpg"
```

```r
# downloads the movie poster jpg from the url
save_file <- file.path(getwd(),"images","poster.jpg")

if(!file.exists(save_file)) {
download.file(poster[1], destfile = save_file, method='curl')
}
```

![If you don't think this is cool, I can't help you.](C:/Users/P1320279/Desktop/Git Folder/Project-Work/.mini guides/Web Scraping/images/poster.jpg)

***
<br />


## Scraping job postings

Finally a quick example of dealing with a common problem. Sometimes when scraping different elements, you will get inconsistent results. This may be due to data that was not inputted or missing.  

The code chunk bellow shows how I dealt with that issue when scraping job postings from jobsDB. I got the job title, company and summary description and formatted it into a table.


```r
# setting url and reading html
url_link <- "https://sg.jobsdb.com/j?q=data+scientist&l=singapore&sp=homepage" 
  
job_pg1 <- read_html(url_link)
  
# function used
getting_data <- function(nodes, css_selector) {
  nodes %>%
    html_nodes(css_selector) %>%
    html_text() %>%
    {
      ifelse (is_empty(.), '-', .)
    }
}

# scraping interested info
job_title <- 
  job_pg1 %>%
  html_nodes(".result") %>%
  map(getting_data, ".jobtitle") %>%
  flatten_chr()

job_company <-
  job_pg1 %>%
  html_nodes(".result")  %>%
  map(getting_data, ".company") %>%
  flatten_chr()

job_summary <-
  job_pg1 %>%
  html_nodes(".result") %>%
  map(getting_data, ".summary") %>%
  flatten_chr()

# formatting output
output <- data.frame(title = job_title, company = job_company, summary = job_summary)
knitr::kable(output) %>% kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> title </th>
   <th style="text-align:left;"> company </th>
   <th style="text-align:left;"> summary </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Data Scientist (Cyber Security) </td>
   <td style="text-align:left;"> Singapore Telecommunications Limited </td>
   <td style="text-align:left;"> We are looking for a creative data scientist to join our project team that builds robust cyber security software and services. The candidate will be... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Associate Data Scientist </td>
   <td style="text-align:left;"> CrimsonLogic Pte Ltd - Global eTrade Services </td>
   <td style="text-align:left;"> The Data Scientist shall work with the product manager to propose &amp; implement the data analytics, ML &amp; AI use cases in the product. Key Accountabilities The... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist/Engineer (MNC / Annual Package of $180K / Central) </td>
   <td style="text-align:left;"> Search Index Pte Ltd </td>
   <td style="text-align:left;"> Including attractive bonuses, annual package up to $180K Location: Central 5-day work week To apply, please click the APPLY NOW button or email your detailed... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Junior Data Scientist (CLT) Job </td>
   <td style="text-align:left;"> MSD </td>
   <td style="text-align:left;"> We are seeking energetic, forward-thinking professionals to join our Information Technology hub in Singapore. As part of that team, you will join the... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Junior Data Scientist </td>
   <td style="text-align:left;"> THE ADVERTISER </td>
   <td style="text-align:left;"> As a CLT data scientist, you will be attached to one of our two data science teams – Decision Sciences and AI Products. You will be provided a holistic... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist </td>
   <td style="text-align:left;"> Biofourmis Singapore </td>
   <td style="text-align:left;"> You will be assisting the Data Scientist Team to: * Perform required bio-signal processing based on the instructions from data scientists. * Evaluate the... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist </td>
   <td style="text-align:left;"> Capgemini Singapore Pte Ltd </td>
   <td style="text-align:left;"> Explore and analyse complex data sets to formulate models Implement complex KPIs for various business domains Work with super users to implement complex... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist (Junior) </td>
   <td style="text-align:left;"> IT Consulting Solutions Singapore Pte. Ltd. </td>
   <td style="text-align:left;"> Scope and build proof-of-concepts / prototypes using data science techniques directly Conceive, develop, and test algorithms with tools like R, Python,... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist - Financial Services </td>
   <td style="text-align:left;"> - </td>
   <td style="text-align:left;"> With this comes an exciting opportunity for inspiring individuals to join the high performing data scientist team. The team works alongside with specific... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist - Fashion Company </td>
   <td style="text-align:left;"> RegionUP </td>
   <td style="text-align:left;"> If you are driven and seek advancement in your career within data analysis, this Data Scientist role will be a good fit for you. [Country]... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist </td>
   <td style="text-align:left;"> Macdonald &amp; Company </td>
   <td style="text-align:left;"> We are partnering with one of Singapore’s largest financial institutions, looking for a Data Scientist to support our expanding Advanced Analytics team. The... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist </td>
   <td style="text-align:left;"> Lomotif </td>
   <td style="text-align:left;"> Lomotif is expanding quickly and is looking for an innovative data scientist who is passionate about solving real-world problems. If you think you fit the... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist </td>
   <td style="text-align:left;"> - </td>
   <td style="text-align:left;"> Our client is one of the well established MNCs in Asia with specialisation in Big Data and Data Analytic in the financial sector. It has a strong regional... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Scientist (Data Analytics) / I2R -18/I2R/0107 </td>
   <td style="text-align:left;"> Institute for Infocomm Research </td>
   <td style="text-align:left;"> We are looking for highly-motivated and skilled data scientist to work on a new initiative on developing advanced automatic data pre-processing techniques... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist I - (216924) </td>
   <td style="text-align:left;"> Jabil Inc. </td>
   <td style="text-align:left;"> Jabil is building a Data Scientist Team. We are looking for junior data scientist who will support the Lead Data Scientist to deliver a wide range of data... </td>
  </tr>
</tbody>
</table>

<br />

<span style = "color:Black">***We can also navigate to different pages***</span>  
You can see how it is possible to design a crawler that will look for the pages interested in and then scrape them. 


```r
# opens html session so enable navigation
open_session <- html_session(url_link)

# reads html for pg2
job_pg2 <- 
  open_session %>%
  follow_link("Next") %>%
  read_html()
```

```
## Navigating to /j?l=singapore&p=2&q=data+scientist&sp=homepage&surl=0&tk=uFvvDwXk4XVF1ir8dBs8-uQC5Q3VcIsePKDKAEsvJ
```

```r
# scraping interested info  
job_title <- 
  job_pg2 %>%
  html_nodes(".result") %>%
  map(getting_data, ".jobtitle") %>%
  flatten_chr()

job_company <-
  job_pg2 %>%
  html_nodes(".result")  %>%
  map(getting_data, ".company") %>%
  flatten_chr()

job_summary <-
  job_pg2 %>%
  html_nodes(".result") %>%
  map(getting_data, ".summary") %>%
  flatten_chr()

# formatting output
output <- data.frame(title = job_title, company = job_company, summary = job_summary)
knitr::kable(output) %>% kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> title </th>
   <th style="text-align:left;"> company </th>
   <th style="text-align:left;"> summary </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Data Scientist </td>
   <td style="text-align:left;"> Kaishi Partners </td>
   <td style="text-align:left;"> Kaishi Partners (16C8316) is working in partnership with a leading Data Technology Firm in Asia to seek a talented Data Scientist in the field of Natural... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist </td>
   <td style="text-align:left;"> Michael Page </td>
   <td style="text-align:left;"> An exciting opportunity to join a Fortune 500 conglomerate as their Data Scientist. Client Details Our client is a Fortune 500 company with an excellent... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist </td>
   <td style="text-align:left;"> Ministry of Home Affairs </td>
   <td style="text-align:left;"> We are seeking candidates who are interested in machine learning to join our analytics team. As a data scientist in MHA, you will be working with advanced... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist </td>
   <td style="text-align:left;"> CAPGEMINI SINGAPORE PTE. LTD. </td>
   <td style="text-align:left;"> We are looking for Data Scientist for a project related to the BFSI domain. The Ideal candidate will be responsible for sourcing data, transform data,... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist </td>
   <td style="text-align:left;"> - </td>
   <td style="text-align:left;"> H2I is looking for a data scientist to join our data scientist team in Singapore. As part of the team, you will help developing added value from public and... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist </td>
   <td style="text-align:left;"> - </td>
   <td style="text-align:left;"> We are looking for a Data Scientist that will help us discover the information hidden in vast amounts of data through signal processing as well as data... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist </td>
   <td style="text-align:left;"> THATZ International Pte Ltd </td>
   <td style="text-align:left;"> Are you the right person we are looking for as our team player to support our business growth? As part of our Next-Generation ICT Engagement and Consultancy... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist (Salary open for discussion) </td>
   <td style="text-align:left;"> Recruitment Hub Asia </td>
   <td style="text-align:left;"> Analyze raw data: assessing quality, cleansing, structuring for management review Identify what data is available and relevant for problem solving Design... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DATA SCIENTIST </td>
   <td style="text-align:left;"> RegionUP </td>
   <td style="text-align:left;"> Post-graduate degrees and/or Bachelor’s Degree in Data Science, Computer Science, Management Information Systems, Engineering, Statistics, Mathematics or... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist (start-up) </td>
   <td style="text-align:left;"> Capita Pte Ltd - IT Perm </td>
   <td style="text-align:left;"> What are we looking for? • Solid practical experience with ETL, data processing and data analytics • Proficiency and hands-on experience in machine learning,... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Principal Data Scientist </td>
   <td style="text-align:left;"> - </td>
   <td style="text-align:left;"> Love buying and selling on Carousell? Then meet the team that handcrafts various parts of the mobile applications, website and backend systems in order to... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist </td>
   <td style="text-align:left;"> IBM Manufacturing Solutions Pte Ltd </td>
   <td style="text-align:left;"> Minimum of 5 years of overall IT experience of which 2 years should be in data analytics , data modelling and data integration using SPSS. Experience in... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Scientist (Data Analytics) / I2R (A*STAR) -18/I2R/0044 </td>
   <td style="text-align:left;"> Institute for Infocomm Research </td>
   <td style="text-align:left;"> We are looking for a capable and responsible scientist to work on a major big data R&amp;D project on fraud risk prediction. Researchers with multi-disciplinary... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Scientist (Data Analytics) / I2R (A*STAR) -18/I2R/0045 </td>
   <td style="text-align:left;"> Institute for Infocomm Research </td>
   <td style="text-align:left;"> We are looking for a capable and responsible scientist to work on a major big data R&amp;D project on fraud risk prediction. Researchers with multi-disciplinary... </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Data Scientist (Watson Analytic, Cognos, Bluemix) </td>
   <td style="text-align:left;"> OPUS IT Services Pte Ltd </td>
   <td style="text-align:left;"> Bachelor's degree or equivalent experience in quantitative field (Statistics, Mathematics, Computer Science, Engineering, Business Analytic etc.) 3 years of... </td>
  </tr>
</tbody>
</table>

***
<br />

## Parting notes

Rvest is just the beginning. There are many problems that occur when scraping websites and there are more comprehensive guides which detail them in the references.  
I wrote this mainly to practise as I learned and to compile all the good notes other people have made into one location for my reference.  

***
<br />
