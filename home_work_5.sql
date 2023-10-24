with total_facebook_and_google as (
  select 
    ad_date,
    campaign_name,
    adset_name,
    spend,
    impressions,
    reach,
    clicks,
    leads,
    value,
    url_parameters,
    coalesce (null, 0)
  from facebook_ads_basic_daily fabd 
  left join facebook_adset fa on fa.adset_id = fabd.adset_id
  left join facebook_campaign fc on fc.campaign_id = fabd.campaign_id
  union 
  select 
    ad_date,
    campaign_name,
    adset_name,
    spend,
    impressions,
    reach,
    clicks,
    leads,
    value,
    url_parameters,
    coalesce(null, 0)
  from google_ads_basic_daily gabd 
  order by 1
)
select 
  ad_date,
  case
  	when url_parameters like '%utm_campaign=nan'then null
  	else substring(url_parameters, 'utm_campaign=([^&#$]+)')
  end as utm_campaign,
  sum(spend) as total_spend,
  sum(clicks) as total_clicks,
  sum(reach) as total_reach,
  sum(value) as total_value,
  round((case when sum(impressions) !=0 then sum(clicks)::numeric/sum(impressions) end),2) as ctr,
  round((case when sum(clicks) !=0 then sum(spend)::numeric/sum(clicks)end),2) as cpc,
  round(( case when sum(impressions) !=0 then sum(spend)::numeric/sum(impressions)end),2) as cpm,
  round((case when sum(spend) !=0 then (sum(value)-sum(spend))::numeric/sum(spend)end),2) as romi
from total_facebook_and_google
group by ad_date, utm_campaign;