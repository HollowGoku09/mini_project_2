"""
app/utils.py
============
UI styling utilities, data vintage banners, sample size disclaimers,
and reusable Plotly chart builders for Streamlit Web App.
"""

import streamlit as st
import plotly.express as px
import plotly.graph_objects as go

def render_vintage_banner():
    """Render mandatory prominent data vintage banner."""
    st.markdown(
        """
        <div style="background-color: #1E293B; border-left: 4px solid #3B82F6; padding: 12px 16px; border-radius: 4px; margin-bottom: 20px;">
            <span style="color: #94A3B8; font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;">Data Snapshot Vintage</span><br/>
            <span style="color: #F8FAFC; font-size: 15px; font-weight: 500;">Based on <b>787,686 job postings</b> collected during 2023. Scope: 91% Data Roles, 9% Software/Cloud/ML.</span>
        </div>
        """,
        unsafe_allow_html=True
    )

def render_salary_disclaimer(sample_count: int, pct_coverage: float = 4.2):
    """Render mandatory salary sample size disclosure card."""
    st.markdown(
        f"""
        <div style="background-color: #0F172A; border: 1px solid #334155; padding: 10px 14px; border-radius: 6px; margin: 10px 0px 20px 0px;">
            <span style="color: #F59E0B; font-weight: 600;">⚠️ Academic Salary Sparsity Disclaimer:</span> 
            <span style="color: #CBD5E1;">Based on <b>{sample_count:,} disclosed postings</b> ({pct_coverage}% overall dataset coverage). Salary averages are presented for disclosed postings only and must not be inferred as market-wide totals.</span>
        </div>
        """,
        unsafe_allow_html=True
    )

def plot_bar_chart(df, x_col, y_col, title, color_col=None, hover_data=None):
    """Generate dark-themed Plotly bar chart."""
    fig = px.bar(
        df, x=x_col, y=y_col, color=color_col,
        title=title, hover_data=hover_data,
        color_discrete_sequence=px.colors.qualitative.Bold
    )
    fig.update_layout(
        template="plotly_dark",
        plot_bgcolor="#0F172A",
        paper_bgcolor="#0F172A",
        font=dict(color="#F8FAFC"),
        margin=dict(l=40, r=40, t=50, b=40)
    )
    return fig

def plot_line_chart(df, x_col, y_col, color_col, title):
    """Generate dark-themed Plotly line chart."""
    fig = px.line(
        df, x=x_col, y=y_col, color=color_col,
        title=title, markers=True
    )
    fig.update_layout(
        template="plotly_dark",
        plot_bgcolor="#0F172A",
        paper_bgcolor="#0F172A",
        font=dict(color="#F8FAFC")
    )
    return fig
