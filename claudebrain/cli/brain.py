#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ClaudeBrain CLI - Memory management for Claude Code sessions

Usage:
    python brain.py start "Working on recruiter dashboard filters"
    python brain.py end 42 "Fixed keyword filter to handle multi-user clusters" success
    python brain.py decision 42 "Use direct links for downloads" "Blob conversion corrupts files"
    python brain.py gotcha 42 "Filter not handling clusters" "Need to rebuild dots from scratch"
    python brain.py search "dashboard filter"
    python brain.py recent
"""

import psycopg2
import psycopg2.extras
import sys
import os
from datetime import datetime
import json

# Fix Windows console encoding
if sys.platform == 'win32':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

# Database connection parameters
DB_CONFIG = {
    'host': 'localhost',
    'port': 5434,
    'database': 'claude_memory',
    'user': 'claude',
    'password': 'dev_only_password'
}

def get_connection():
    """Get database connection"""
    try:
        return psycopg2.connect(**DB_CONFIG)
    except psycopg2.Error as e:
        print(f"❌ Database connection failed: {e}")
        print("Make sure Docker container is running: docker-compose up -d")
        sys.exit(1)

def start_session(user_goal, project_name='myresumechat'):
    """Start a new coding session"""
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute(
            "SELECT start_session(%s, %s)",
            (user_goal, project_name)
        )
        session_id = cur.fetchone()[0]
        conn.commit()

        print(f"✅ Session started: #{session_id}")
        print(f"📝 Goal: {user_goal}")
        print(f"📁 Project: {project_name}")
        print(f"\n💡 Remember to log your work with:")
        print(f"   python brain.py decision {session_id} \"your decision\" \"reasoning\"")
        print(f"   python brain.py gotcha {session_id} \"problem\" \"solution\"")
        print(f"   python brain.py end {session_id} \"summary\" success")

        return session_id
    except Exception as e:
        conn.rollback()
        print(f"❌ Error starting session: {e}")
    finally:
        cur.close()
        conn.close()

def end_session(session_id, summary, outcome='success'):
    """End a coding session"""
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute(
            "SELECT end_session(%s, %s, %s)",
            (session_id, summary, outcome)
        )
        conn.commit()

        print(f"✅ Session #{session_id} ended")
        print(f"📊 Outcome: {outcome}")
        print(f"📝 Summary: {summary}")

        # Show session stats
        cur.execute("""
            SELECT
                COUNT(DISTINCT f.id) as files_changed,
                COUNT(DISTINCT d.id) as decisions_made,
                COUNT(DISTINCT g.id) as gotchas_logged
            FROM sessions s
            LEFT JOIN files_modified f ON s.id = f.session_id
            LEFT JOIN decisions d ON s.id = d.session_id
            LEFT JOIN gotchas g ON s.id = g.session_id
            WHERE s.id = %s
        """, (session_id,))

        stats = cur.fetchone()
        print(f"\n📈 Session stats:")
        print(f"   Files changed: {stats[0]}")
        print(f"   Decisions logged: {stats[1]}")
        print(f"   Gotchas logged: {stats[2]}")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error ending session: {e}")
    finally:
        cur.close()
        conn.close()

def log_decision(session_id, decision, reasoning, alternatives=None, tags=None):
    """Log an important decision"""
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            INSERT INTO decisions (session_id, decision, reasoning, alternatives_considered, tags)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id
        """, (session_id, decision, reasoning, alternatives, tags or []))

        decision_id = cur.fetchone()[0]
        conn.commit()

        print(f"✅ Decision logged: #{decision_id}")
        print(f"📝 {decision}")
        if reasoning:
            print(f"💭 Reasoning: {reasoning}")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error logging decision: {e}")
    finally:
        cur.close()
        conn.close()

def log_gotcha(session_id, problem, solution, file_path=None, error_msg=None, time_wasted=None, severity='moderate'):
    """Log a problem and its solution"""
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            INSERT INTO gotchas (session_id, problem, solution, file_path, error_message, time_wasted_minutes, severity)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """, (session_id, problem, solution, file_path, error_msg, time_wasted, severity))

        gotcha_id = cur.fetchone()[0]
        conn.commit()

        print(f"✅ Gotcha logged: #{gotcha_id}")
        print(f"⚠️  Problem: {problem}")
        print(f"✨ Solution: {solution}")
        if file_path:
            print(f"📄 File: {file_path}")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error logging gotcha: {e}")
    finally:
        cur.close()
        conn.close()

def log_file(session_id, file_path, change_type='modified', change_summary=None):
    """Log a file modification"""
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            INSERT INTO files_modified (session_id, file_path, change_type, change_summary)
            VALUES (%s, %s, %s, %s)
            RETURNING id
        """, (session_id, file_path, change_type, change_summary))

        file_id = cur.fetchone()[0]
        conn.commit()

        print(f"✅ File logged: #{file_id}")
        print(f"📄 {file_path} ({change_type})")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error logging file: {e}")
    finally:
        cur.close()
        conn.close()

def search_context(search_term, limit=20):
    """Search for relevant context"""
    conn = get_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    try:
        print(f"🔍 Searching for: '{search_term}'...\n")

        cur.execute("SELECT * FROM search_context(%s, %s)", (search_term, limit))
        results = cur.fetchall()

        if not results:
            print("No results found.")
            return

        for i, row in enumerate(results, 1):
            print(f"{'='*80}")
            print(f"#{i} [{row['source'].upper()}] - Session #{row['session_id']} ({row['session_date']})")
            print(f"{'-'*80}")
            print(row['content'])
            print()

    except Exception as e:
        print(f"❌ Error searching: {e}")
    finally:
        cur.close()
        conn.close()

def show_recent(limit=10):
    """Show recent sessions"""
    conn = get_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    try:
        print(f"📅 Recent sessions:\n")

        cur.execute("SELECT * FROM recent_sessions LIMIT %s", (limit,))
        sessions = cur.fetchall()

        for session in sessions:
            print(f"{'='*80}")
            print(f"Session #{session['id']} - {session['session_date']}")
            print(f"Project: {session['project_name'] or 'N/A'}")
            if session['summary']:
                print(f"Summary: {session['summary']}")
            print(f"Activity: {session['files_changed']} files, {session['decisions_made']} decisions, {session['gotchas_encountered']} gotchas")
            print()

    except Exception as e:
        print(f"❌ Error fetching recent sessions: {e}")
    finally:
        cur.close()
        conn.close()

def show_stats():
    """Show database statistics"""
    conn = get_connection()
    cur = conn.cursor()

    try:
        print("📊 ClaudeBrain Statistics\n")

        cur.execute("SELECT COUNT(*) FROM sessions")
        print(f"   Total sessions: {cur.fetchone()[0]}")

        cur.execute("SELECT COUNT(*) FROM files_modified")
        print(f"   Files modified: {cur.fetchone()[0]}")

        cur.execute("SELECT COUNT(*) FROM decisions")
        print(f"   Decisions logged: {cur.fetchone()[0]}")

        cur.execute("SELECT COUNT(*) FROM gotchas")
        print(f"   Gotchas logged: {cur.fetchone()[0]}")

        cur.execute("SELECT COUNT(*) FROM code_patterns")
        print(f"   Code patterns: {cur.fetchone()[0]}")

        print("\n📈 Most changed files:")
        cur.execute("SELECT * FROM file_change_frequency LIMIT 5")
        for row in cur.fetchall():
            print(f"   {row[0]}: {row[1]} times")

    except Exception as e:
        print(f"❌ Error fetching stats: {e}")
    finally:
        cur.close()
        conn.close()

def show_help():
    """Show help message"""
    print("""
🧠 ClaudeBrain CLI - Memory for Claude Code

COMMANDS:
  start <goal> [project]          Start new session
  end <session_id> <summary> [outcome]   End session
  decision <session_id> <decision> <reasoning>   Log decision
  gotcha <session_id> <problem> <solution>       Log gotcha
  file <session_id> <path> [type] [summary]      Log file change
  search <term>                   Search context
  recent [limit]                  Show recent sessions
  stats                          Show statistics
  help                           Show this help

EXAMPLES:
  python brain.py start "Fix recruiter dashboard filter"
  python brain.py decision 42 "Use direct links" "Blob corrupts binary"
  python brain.py gotcha 42 "Filter breaks on clusters" "Rebuild from scratch"
  python brain.py file 42 "dashboard.html" modified "Fixed keyword filter"
  python brain.py search "filter"
  python brain.py end 42 "Fixed filter for multi-user clusters" success

CONNECTION:
  Database: claude_memory
  Host: localhost:5434
  User: claude
    """)

def main():
    if len(sys.argv) < 2:
        show_help()
        return

    command = sys.argv[1].lower()

    try:
        if command == 'start':
            if len(sys.argv) < 3:
                print("Usage: python brain.py start <goal> [project]")
                return
            goal = sys.argv[2]
            project = sys.argv[3] if len(sys.argv) > 3 else 'myresumechat'
            start_session(goal, project)

        elif command == 'end':
            if len(sys.argv) < 4:
                print("Usage: python brain.py end <session_id> <summary> [outcome]")
                return
            session_id = int(sys.argv[2])
            summary = sys.argv[3]
            outcome = sys.argv[4] if len(sys.argv) > 4 else 'success'
            end_session(session_id, summary, outcome)

        elif command == 'decision':
            if len(sys.argv) < 5:
                print("Usage: python brain.py decision <session_id> <decision> <reasoning>")
                return
            session_id = int(sys.argv[2])
            decision = sys.argv[3]
            reasoning = sys.argv[4]
            log_decision(session_id, decision, reasoning)

        elif command == 'gotcha':
            if len(sys.argv) < 5:
                print("Usage: python brain.py gotcha <session_id> <problem> <solution>")
                return
            session_id = int(sys.argv[2])
            problem = sys.argv[3]
            solution = sys.argv[4]
            log_gotcha(session_id, problem, solution)

        elif command == 'file':
            if len(sys.argv) < 4:
                print("Usage: python brain.py file <session_id> <path> [type] [summary]")
                return
            session_id = int(sys.argv[2])
            file_path = sys.argv[3]
            change_type = sys.argv[4] if len(sys.argv) > 4 else 'modified'
            summary = sys.argv[5] if len(sys.argv) > 5 else None
            log_file(session_id, file_path, change_type, summary)

        elif command == 'search':
            if len(sys.argv) < 3:
                print("Usage: python brain.py search <term>")
                return
            search_term = sys.argv[2]
            search_context(search_term)

        elif command == 'recent':
            limit = int(sys.argv[2]) if len(sys.argv) > 2 else 10
            show_recent(limit)

        elif command == 'stats':
            show_stats()

        elif command in ['help', '-h', '--help']:
            show_help()

        else:
            print(f"Unknown command: {command}")
            show_help()

    except KeyboardInterrupt:
        print("\n\nInterrupted by user")
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    main()
