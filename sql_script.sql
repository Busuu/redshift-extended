create or replace function is_json(j varchar(max))
returns boolean
stable as $$
    import json
    try:
        json_object = json.loads(j)
    except ValueError, e:
        return False
    return True
$$ language plpythonu;


create or replace function epoch_to_timestamp(j bigint)
returns timestamp 
stable as $$
    import datetime
    if len(str(j)) > 10:
        j= round(j/1000)
    return datetime.datetime.fromtimestamp(j)
$$ language plpythonu;


create or replace function is_int(j int)
returns boolean 
stable as $$
    try:
        if isinstance(int(j), ( int, long)):
            return True
        else:
            return False
    except Exception as e:
        return False
$$ language plpythonu;

create or replace function epoch_to_timestamp_string(j varchar(max))
returns timestamp 
stable as $$
    import datetime
    j = str(j).strip()
    try:
        j = int(j)
        if len(str(j)) > 10:
            j= round(j/1000)
        return datetime.datetime.fromtimestamp(j)
    except Exception as e:
        return None
$$ language plpythonu;

create or replace function grab_json_field(json_field varchar(max), field varchar(max)) 
returns varchar(max) 
stable as $$ 
    import json
    j = str(json_field).strip()
    fields = field.split("-")
    try:
        output = json.loads(j)
        for i in range(0,len(fields)): 
            output = output[fields[i]]
        return str(output)
    except Exception as e:
        return None
$$ language plpythonu;


create or replace function grab_broken_json_field(json_field varchar(max), field varchar(max)) 
returns varchar(max) 
stable as $$ 
    import re
    matches = re.search('"%s":"(.*?)(")' %field , json_field)
    if matches:
        return matches.group(1)
    else:
        return None 
$$ language plpythonu;


create or replace function is_float(j varchar)
returns boolean 
stable as $$
    try:
        if isinstance(j, int):
            if j % 1 > 0.0:
                return True
            else:
                return False
        else:
            return False
    except Exception as e:
        return False
$$ language plpythonu;


create or replace function round_to_nearest(j float, x int)
returns int 
stable as $$
    try:
        if isinstance(j, int):
            j= float(j)
        return round(j/x)*x
    except Exception as e:
        return None
$$ language plpythonu;


create or replace function hourpart_24_to_12(j int)
returns varchar
stable as $$
    if j > 23 or j < 0 :
        return None
    else:
        if j == 0:
            return "12 AM"
        if j == 12:
            return "12 PM"
        if j < 13:
            return "%s AM" % j
        else:
            return "%s PM" % (j -12)
$$ language plpythonu;
  

create or replace function num_objects_in_json(j varchar)
returns integer
stable as $$
    import json
    try:
        jsondata = json.loads(j)
        return len(jsondata)
    except Exception as e:
        return None
$$ language plpythonu;


create or replace function json_keys(j varchar(max))
returns varchar(max)
stable as $$
    import json
    try:
        jsondata = json.loads(json.dumps(j))
        return json.dumps([x for x in json.loads(jsondata)]) 
    except Exception as e: 
        return str(e)
$$ language plpythonu;


create or replace function day_of_week(j varchar(max)) 
returns varchar(max) 
stable as $$ 
    import datetime
    try:
        return datetime.datetime.strptime(j, '%Y-%m-%d %H:%M:%S').strftime("%A")
    except Exception as e:
        return datetime.datetime.strptime(j, '%Y-%m-%d').strftime("%A")
$$ language plpythonu;


create or replace function statistical_significance(a int, A int, b int, B int ) 
returns varchar(max) 
stable as $$ 
    from scipy.stats import norm
    try:
        s1 = float(a)
        n1 = float(A)
        s2 = float(b)
        n2 = float(B)
        p1 = s1/n1
        p2 = s2/n2
        p = (s1 + s2)/(n1+n2)
        
        z = (p2-p1)/ ((p*(1-p)*((1/n1)+(1/n2)))**0.5)
        
        if p1 > p2:
            winner = "A"
            by = (p1-p2)/p2
            p_value = (1- norm.cdf(z)) + 0.01
        else:
            winner = "B"
            by = (p2-p1)/p1
            p_value = norm.cdf(z) + 0.01
        
        if p_value >= 0.95:
            result = "Statistically Significant"
        else:
            result = "Not Statistically Significant"
        
        return "winner= %s :: improvement= %s%% :: confidence= %s%% :: %s" % (winner, round(by*100), round(p_value*100), result)
    except Exception as e: 
        return "Error"
$$ language plpythonu;