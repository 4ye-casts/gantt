class Person
  constructor: (@name)->
    # nothing

class TaskBundle
  TASK_DOM_HEIGHT: 40
  
  constructor: (@data)->

    @person = @data.person
    @desc = @data.desc
    @start_day = new Date(@data.start)
    @end_day = new Date(@data.end)

    @is_milestone = @data.is_milestone
    @is_finished = @data.is_finished
    @is_waiting = @data.is_waiting
    @is_active = @data.is_active

    @children = []
    if @data.children
      @children = for c in @data.children
        new TaskBundle c


  render_on: (gantt_ui, depth)->
    $container = gantt_ui.$tasks

    top = gantt_ui.tasks_count * @TASK_DOM_HEIGHT+ 20
    gantt_ui.tasks_count++

    $elm = jQuery '<div>'
      .addClass 'task-bundle'
      .css
        'top': top
      .appendTo $container

    if @children and @children.length
      $elm.addClass 'with-children'

      @start_day = Infinity
      @end_day = 0
      for c in @children
        c.render_on gantt_ui, depth + 1
        @start_day = new Date Math.min(@start_day, c.start_day)
        @end_day = new Date Math.max(@end_day, c.end_day)
      if depth is 0 then gantt_ui.tasks_count++
    else

    [width, left] = @_get_width_and_left @start_day, @end_day
    
    $elm
      .css
        'width': width
        'left': left
      .appendTo $container

    $text = jQuery '<div>'
      .addClass 'text'
      .appendTo $elm

    $person = jQuery '<span>'
      .addClass 'person'
      .html @person || '任务集合'
      .appendTo $text

    $desc = jQuery '<span>'
      .addClass 'desc'
      .html @desc
      .appendTo $text

    if @is_milestone
      $elm
        .addClass 'milestone'
        .find '.person'
        .html '里程碑'

    if @is_finished
      $elm
        .addClass 'finished'

    if @is_waiting
      $elm
        .addClass 'waiting'

    if @is_active
      $elm
        .addClass 'active'

  _get_width_and_left: (start_day, end_day)->
    width = (end_day.getDate() - start_day.getDate() + 1) * 50
    left = 50 * (start_day.getDate() - 1)
    return [width, left]

class GanttUI
  constructor: ->
    @tasks_count = 0

    @build()

  build: ->
    @build_elm()
    @build_days()
    @build_tasks()

  build_elm: ->
    @$elm = jQuery '<div>'
      .addClass 'gantt'
      .appendTo jQuery(document.body)

    # TODO 左右滚动按钮

    main_width = ~~((jQuery(document).width() - 70 * 2) / 50) * 50

    @$main = jQuery '<div>'
      .addClass 'main-area'
      .css 'width', main_width
      .appendTo @$elm

  build_days: ->
    @$days = jQuery '<div>'
      .addClass 'days'
      .css 'width', 60 * 50
      .appendTo @$main

    today = new Date()
    month = today.getMonth() + 1
    year = today.getFullYear()

    first_day = new Date "#{year}-#{month}-1"
    for i in [0...60]
      day = new Date first_day.getTime()
      day.setDate day.getDate() + i
      date_ui = new DateUI(day, @$days)

  build_tasks: ->
    $tasks_scroller = jQuery '<div>'
      .addClass 'tasks-scroller'
      .appendTo @$main

    @$tasks = jQuery '<div>'
      .addClass 'tasks'
      .appendTo $tasks_scroller

      
class DateUI
  constructor: (day, $container)->
    @$elm = jQuery('<div>')
      .addClass 'day'
      .appendTo $container

    if day.getDay() is 0
      @$elm.addClass 'sunday'
    if day.getDay() is 6
      @$elm.addClass 'saturday'

    today = new Date()
    if day.getDate() is today.getDate() and
       day.getMonth() is today.getMonth() and
       day.getFullYear() is today.getFullYear()

      @$elm.addClass 'today'


    arr = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ]

    $month = jQuery '<div>'
      .addClass 'month'
      .html arr[day.getMonth()]
      .appendTo @$elm

    $date = jQuery '<div>'
      .addClass 'date'
      .html day.getDate()
      .appendTo @$elm



jQuery ->
  gantt_ui = new GanttUI()

  jQuery.getJSON "./data.json?#{Math.random()}", (data)->
    for d in data
      tb = new TaskBundle(d)
      tb.render_on gantt_ui, 0

    console.log gantt_ui.tasks_count
    gantt_ui.$tasks.css 'height', gantt_ui.tasks_count * 40 + 20

# TODO
  # 子任务 -> ok
  # 里程碑
  # 后续任务
  # 伴随任务
  # 不确定结束日期的任务 uncertainty