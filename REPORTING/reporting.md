## Example of report preparation using Python

Unfortunately I cant share data that I'm using in report preparation because it violates the data privacy policy

Key points

**1. Data extraction**
    - For this report I'm using more that 10 different files

**2. Visualistion code**
    - Example:

``` Python

# строим сводную таблицу по buyers_profile для последующего построения графиков
filter_buyers_prof = buyers_profile[(buyers_profile['country']=='RU') | (buyers_profile['country']=='KZ')]
filter_buyers_prof[['% of recruits buying wellness', '% of leaders buying wellness']] = filter_buyers_prof[['% of recruits buying wellness', '% of leaders buying wellness']].fillna(0)
pivot_buyers = pd.pivot_table(filter_buyers_prof, values=['% of consultants buying wellness', '% of recruits buying wellness', '% of leaders buying wellness'], index=['Year', 'catalogue', 'country'],
                         aggfunc=np.sum)
pivot_buyers = pivot_buyers.reset_index()
pivot_buyers = pivot_buyers.sort_values(by=['Year', 'catalogue'], axis=0)
pivot_buyers = pivot_buyers.replace([np.inf, -np.inf], 0)

# добавляем новые признкаи в сводную таблицу 
pivot_buyers['period'] = pivot_buyers['Year'].astype('str') + ' - ' + pivot_buyers['catalogue'].astype('str')
pivot_buyers[['% of consultants buying wellness', '% of leaders buying wellness', '% of recruits buying wellness']] = pivot_buyers[['% of consultants buying wellness', '% of leaders buying wellness', '% of recruits buying wellness']].fillna(0).astype(int)
pivot_buyers[['Year', 'catalogue']] = pivot_buyers[['Year', 'catalogue']].astype(int)

# делим сводную таблицу на три региона по кторым необходимо построить графики 
data_RU = pivot_buyers[(pivot_buyers["country"] == 'RU') & (pivot_buyers["% of consultants buying wellness"] > 0) & (pivot_buyers["Year"] >= 2021)]
data_RU = data_RU.sort_values(by=['Year', 'catalogue'], axis=0)

data_KZ = pivot_buyers[(pivot_buyers["country"] == 'KZ') & (pivot_buyers["% of consultants buying wellness"] > 0) & (pivot_buyers["Year"] >= 2021)]
data_KZ = data_KZ.sort_values(by=['Year', 'catalogue'], axis=0)

# строим графики 
# set up plotly figure
fig = make_subplots(
    rows = 3, cols = 1,
    subplot_titles=('% of ASF buying Wellness', '% of Leaders buying Wellness', '% of Recruits buying Wellness')) #,  '% of leaders buying wellness', '% of recruits buying wellness'))

# add first scatter trace at row = 1, col = 1
fig.add_trace(go.Scatter(x=data_RU['period'], y=data_RU['% of consultants buying wellness'], line=dict(color='green'), name='RU'),
              row = 1, col = 1)

# add first bar trace at row = 3, col = 2
fig.add_trace(go.Scatter(x=data_KZ['period'], y=data_KZ['% of consultants buying wellness'], line=dict(color='orange'), name='KZ'),
              row = 1, col = 1)

# add first scatter trace at row = 1, col = 1
fig.add_trace(go.Scatter(x=data_RU['period'], y=data_RU['% of leaders buying wellness'], line=dict(color='green'), showlegend=False),
              row = 2, col = 1)

# add first bar trace at row = 3, col = 2
fig.add_trace(go.Scatter(x=data_KZ['period'], y=data_KZ['% of leaders buying wellness'], line=dict(color='orange'), showlegend=False),
              row = 2, col = 1)


# add first scatter trace at row = 1, col = 1
fig.add_trace(go.Scatter(x=data_RU['period'], y=data_RU['% of recruits buying wellness'], line=dict(color='green'), showlegend=False),
              row = 3, col = 1)

# add first bar trace at row = 3, col = 2
fig.add_trace(go.Scatter(x=data_KZ['period'], y=data_KZ['% of recruits buying wellness'], line=dict(color='orange'), showlegend=False),
              row = 3, col = 1)


fig.update_layout(height=700, width=1100)
fig.update_xaxes(dtick=1, tickangle = 45)
fig.update_traces(textposition="bottom right")
```

**3. Excel report generation exmaple**

``` Python

# сортируем таблицу для вывода 
sales_report = sales_report.sort_values(by=['Year', 'catalogue'])

# меняем названия столбцов на удобные для бизнеса 
sales_report = sales_report.rename(columns={
    'Active_SF PY':'number of active consultants, PY', 'QUANTITY':'Units sold wlns', 'REQUESTED':'Sum of Requested',
    'Sales of code,euro net':'Sales euro net wlns', 'Sales of code, local currency':'Sales LC net wlns', '':'',
    'As gifts':'# of wlns gifts'
})

# меняем тип данных в столбцах на корректные
sales_report[['activity', 'activity PY']] = sales_report[['activity', 'activity PY']].round(1).astype('str').apply(lambda x: x+'%')

# визуализируем таблицу в html и выгружаем ее в excel
import plotly.figure_factory as ff

fig =  ff.create_table(sales_report.tail(100))
fig.layout.width=7400

sales_report.to_excel(r"Wellness sales report.xlsx", index=False) 

```

**4. Automatic sending**

``` Python

import pandas as pd
import os
import codecs

import win32com
import win32com.client as client

# данные форкастов 
RU = accuracy_data_RU['accuracy'].item() 
KZ = accuracy_data_KZ['accuracy'].item() 

values_for_mail = pivot_sales_CIS.dropna().sort_values(by=['catalogue', 'Year'])
values_for_mail  = values_for_mail [(values_for_mail ['catalogue'] == current_catalogue)]

# данные продаж
share_cur = round(values_for_mail ['Wellness share in total sales'].iloc[-1])
share_last = round(values_for_mail ['Wellness share in total sales'].iloc[-2])
sales_cur = round(values_for_mail ['Sales of code,euro net'].iloc[-1] / 1000000, 1)
sales_last = round(values_for_mail ['Sales of code,euro net'].iloc[-2] / 1000000, 1)

mail_data = pd.read_excel(r'\mail.xlsx')

mail_to = mail_data['To'][mail_data['To'].notna()].values
mail_cc = mail_data['Cc'][mail_data['Cc'].notna()].values

to = []
cc = []

for i in mail_to:
    to.append(i)
    
for i in mail_cc:
    cc.append(i)

display(to)
display(cc)

signature_path = os.path.join((os.environ['USERPROFILE']),'AppData\Roaming\Microsoft\Signatures\Email Signature ().htm') # Fth to Outlook signinds the paature files with signature name "Work"
html_doc = os.path.join((os.environ['USERPROFILE']),'AppData\Roaming\Microsoft\Signatures\Email Signature ().htm')     #Specifies the name of the HTML version of the stored signature
html_doc = html_doc.replace('\\\\', '\\') #Removes escape backslashes from path string


html_file = codecs.open(html_doc, 'r', 'utf-8', errors='ignore') #Opens HTML file and ignores errors
signature_code = html_file.read() #Writes contents of HTML signature file to a string
signature_code = signature_code.replace('Work_files/', signature_path)      #Replaces local directory with full directory path
html_file.close()


inbox = win32com.client.gencache.EnsureDispatch("Outlook.Application").GetNamespace("MAPI")
print(dir(inbox))
inbox = win32com.client.Dispatch("Outlook.Application")
print(dir(inbox))


mail = inbox.CreateItem(0x0)
mail.To = ';'.join(to)
mail.CC = ';'.join(cc)
mail.Subject = f"Wellness sales report C0{current_catalogue} {current_year}'"
html_body = """
    <p> Dear colleagues, </p>
        
    <p>Please find below a short overview of Wellness sales in campaign #""" +str(current_catalogue)+ """ """ +str(current_year)+ """ in CIS. <br>
    Wellness sales share (total CIS) made """ +str(share_cur)+ """% (""" +str(share_last)+ """% in PY). Wellness sales amounted about """ +str(sales_cur)+ """ million euro total CIS (""" +str(sales_last)+ """ million in PY). <br> </p>
    
    <p>More detailed information can be found in the attached file. <br>
    Please let me know if you have any questions. </p>

"""
mail.HTMLBody = html_body + signature_code
mail.Attachments.Add(r"")
mail.Attachments.Add(r"")
mail.Attachments.Add(r"")
# mail.Send()
mail.Display()

```