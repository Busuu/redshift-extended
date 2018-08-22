# Redshift Extended

##### A series of extra functions that build straight into your Redshift cluster
![Alt](https://hevodata.com/blog/wp-content/uploads/2017/10/logo-amazon-redshift-1.png )
![Alt](http://hansmengroup.com/wp-content/uploads/2010/03/busuu_logo.png "busuu")

**AWS Redshift is one of the biggest and best data warehouse tools in industry today. Not only does it hold and allow you to quiery massive amounts of data extremely quickly there are some helpful methods to help munge your data. However it doesn't make sense not to use the huge computing power of your cluster that you are already paying for not to do more of the data munging.** 

**This repo will install a series of extra functions to your redshift cluster that [busuu](https://www.busuu.com "busuu homepage") regular use to help them to do more of your data processing inside their Redshift cluster itself to avoid doing data processing in multiple places and get more value from their Redshift cluster**

##### Functions include
* __Statistical significance calculations__ to confirm hypothesis testing and AB test analyses from your data
* __Additional datetime based functions__ to convert and clean various types of datetime data
* __JSON functions__ to give you the ability to store JSONs as strings inside your database and gain some noSQL functionality to your relational Redshift Cluster
* __Data Validation functions__ to ensure filter away dirty data from your query

##### Prerequisites
1. Make sure your Redshift cluster is up and running. See [AWS Documentation](https://console.aws.amazon.com/redshift/home "Redshift Home") for help.
2. *python3* & *pip3* installed

##### Installation
Open a terminal window and run the following commands:
1. `git clone https://github.com/Busuu/redshift-extended.git`
2. `cd redshift-extended`
3. `python3 redshift_extended.py` 
4. If unsuccessful run `pip3 install -r requirements.txt` and repeat stage 3

--
----
  
#### Extra functionality in Redshift Extended
1. **`statistical_significance(conversions_A_variant, population_A_Variant, conversions_B_Variant, population_B_Variant)`**
When you have worked out the conversion rate of each variant of an AB test experiment and you want to know the statistical confidence of the experiment, this method can work it out for you to give you trust on the results of the experiment or conversion difference. For more on Statisitical Significance see [here](http://blog.analytics-toolkit.com/2017/statistical-significance-ab-testing-complete-guide/, "statistical-significance-ab-testing-complete-guide").
--
**Example**  
Run the following in your favourite redshift SQL client.
`select statistical_significance({conversions in variant A}, {population of variant A}, {conversions in variant B}, {population of variant B});`
..
This will return
`winner= {variant A | variant B} :: improvement= X % :: confidence= X % :: (Not) Statistically Significant`
    
2. **`epoch_to_timestamp(epoch_int)`**
When dealing with system time (epoch times) the common ways to convert these to a timestamp data object can produce errors due to a use of a 10 or 13 digit epoch number being used. This method will take an int column of either 10 or 13 digits and return a timestamp data type.
--
**Example**  
Run the following in your favourite redshift SQL client.
`select epoch_to_timestamp(1534937263000);`
..
This will return
`2018-08-22 11:27:43`

3. **`epoch_to_timestamp_string(epoch_string)`**
When your epoch is in a string column due to dirty data being copied into the cluster, this function works similarly to the function above but takes a varchar column as an input. This method cleans the string of a 10 or 13 digit epoch time and tries to convert them to timestamps. If the variable is not a epoch time, the function will gracefully return a `NULL` for that particular variable.
--
**Example**  
Run the following in your favourite redshift SQL client.
`select epoch_to_timestamp_string(' 1534937263000');`
..
This will return
`2018-08-22 11:27:43`

4. **`hourpart_24_to_12(datepart_int)`**
When charting up a time of day based dataset, your axes will look more human and readable to a non-technical audience if you have the axis running from 1AM to 12AM instead of the hour number from the `datepart()` function going from 0-23. This method will take the int hour of the day and output the time of day in pretty 12 hour time.
--
**Example**  
Run the following in your favourite redshift SQL client.
`select hourpart_24_to_12(date_part(h, '2018-01-01 12:56:01')::int);`
..
This will return
`12 PM`

5. **`day_of_week(datetime)`**
When looking at weekly seasonality in a data pattern, the day of the week can be an important factor to group upon as well as chart against. This method returns a day of the week to group and plot from a timestamp.
--
**Example**  
Run the following in your favourite redshift SQL client.
`select day_of_week('2018-01-01 12:56:01');`
..
This will return
`Monday`

6. **`round_to_nearest(number_to_round, number_to_round_to_the_nearest)`**
Being able to round numbers to the nearest X is important to be able to remove noise from a ML model or categorise user behavior to be able to bin a continuous scale into smaller more discrete buckets. This method takes a number and the nearest number to round it to and creates a new number that is rounded to the nearest X so that it can be grouped or binned.
--
**Example**  
Run the following in your favourite redshift SQL client.
`select round_to_nearest(23, 10);`
..
This will return
`20`

7. **`grab_json_field(JSON_string, field_to_return)`**
One of the biggest restrictions with relational databases is the need to have common fields and datatypes across each row. At busuu we add NoSQL functionality to our Redshift cluster by adding JSON data objects into string columns. The AWS functions that help users do this are error prone and error when dirty data cannot be cast to a JSON type. This function can not only retieve data from __nested JSON fields__ but also can gracefully return `NULL` for broken or dirty data.
--
**Example**  
Run the following in your favourite redshift SQL client.
`select params_json;`
`select grab_json_field(params_json, 'data-event_name');`
..
This will return
`'{"data":{"event_name":"learning_started"}}'`
`learning_started`

8. **`grab_broken_json_field(JSON_string, field_to_return)`**
This is another version of the method above for when there is dirty data is present. This will grab the same field within the nested json and fail gracefully with non valid JSONs. It is more computationally expensive than the grab_json_field() method so should only be used when absolutely necessary.
--
**Example**  
Run the following in your favourite redshift SQL client.
`select params_json;`
`select grab_broken_json_field(params_json, 'event_name');`
..
This will return
`'{"data":{u"event_name":"learning_started"},{"event_name":"certificate_started"}}'`
`learning_started`

9. **`num_objects_in_json(JSON_string)`**
This method can be useful to either filter down JSON strings to only the ones that you want or to see the variance in the number of objects in the JSON field in each row.
--
**Example**  
Run the following in your favourite redshift SQL client.
`select params_json;`
`select num_objects_in_json(params_json);`
..
This will return
`'{"event_name":"busuu_started", "timestamp":1534935159, "platform":"web", "OS_version":"12.3.12"}'`
`4`

10. **`json_keys(JSON_string)`**
This method returns a list of the JSON fields that are in the JSON string. This can again be useful for filtering rows that have a certain field that you are querying in it. 
--
**Example**  
Run the following in your favourite redshift SQL client.
`select params_json;`
`select json_keys(params_json);`
..
This will return
`'{"event_name":"busuu_started", "timestamp":1534935159, "platform":"web", "OS_version":"12.3.12"}'`
`["event_name", "timestamp", "OS_version", "platform"]`

11. **`is_json(JSON_string)`**
This method will return `TRUE` if the JSON string is a valid JSON object and `FALSE` if not
--
**Example**  
Run the following in your favourite redshift SQL client.
`select params_json;`
`select is_json(params_json);`
..
This will return
`'{"event_name":"busuu_started", "timestamp":1534935159, "platform":"web", "OS_version":"12.3.12"}'`
`TRUE`

12. **`is_float(float_varchar)`**
This method will return `TRUE` if the varchar is a valid float data type and `FALSE` if not. This is useful for filtering and identifying dirty data.
--
**Example**  
Run the following in your favourite redshift SQL client.
`select is_float('0.34');`
`select is_float('10.34.12.675');`
..
This will return
`TRUE`
`FALSE`

12. **`is_int(int_varchar)`**
This method will return `TRUE` if the varchar is a valid float data type and `FALSE` if not. This is useful for filtering and identifying dirty data.
--
**Example**  
Run the following in your favourite redshift SQL client.
`select is_int('34');`
`select is_int('10.34.12.675');`
..
This will return
`TRUE`
`FALSE`





