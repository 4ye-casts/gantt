class Person
  constructor: (@name)->
    # nothing

class TaskBundle
  constructor: (@person, @desc, @start_day, @end_day)->
    @TASK_DOM_HEIGHT = 40

    # .....

  render_on: (calendar_ui)->
    width = (@end_day.getDate() - @start_day.getDate() + 1) * 50
    top = calendar_ui.tasks_count * @TASK_DOM_HEIGHT + 66 + 10
    left = 50 * (@start_day.getDate() - 1)

    $elm = jQuery '<div>'
      .addClass 'task-bundle'
      .css
        'width': width
        'top': top
        'left': left
      .appendTo calendar_ui.$days_container

    $text = jQuery '<div>'
      .addClass 'text'
      .appendTo $elm


    $person = jQuery '<span>'
      .addClass 'person'
      .html @person
      .appendTo $text

    $desc = jQuery '<span>'
      .addClass 'desc'
      .html @desc
      .appendTo $text


class CalendarUI
  constructor: ->
    @tasks_count = 0

    @build()

  build: ->
    @build_elm()
    @build_days()

  build_elm: ->
    @$elm = jQuery '<div>'
      .addClass 'calendar'
      .appendTo jQuery(document.body)

  build_days: ->
    window_width = jQuery(document).width()
    elm_width = ~~((window_width - 70 * 2) / 50) * 50

    @$days = jQuery '<div>'
      .addClass 'days'
      .css 'width', elm_width
      .appendTo jQuery(@$elm)

    @$days_container = jQuery '<div>'
      .addClass 'days-container'
      .css 'width', 60 * 50
      .appendTo @$days

    today = new Date()
    month = today.getMonth() + 1
    year = today.getFullYear()

    first_day = new Date "#{year}-#{month}-1"
    for i in [0...60]
      day = new Date first_day.getTime()
      day.setDate day.getDate() + i
      date_ui = new DateUI(day, @)


  add_task_bundle: (task_bundle)->
    task_bundle.render_on @
    @tasks_count++ 


      
class DateUI
  constructor: (day, @calendar)->
    @$elm = jQuery('<div>')
      .addClass 'day'
      .appendTo @calendar.$days_container

    if day.getDay() is 0
      @$elm.addClass 'sunday'
    if day.getDay() is 6
      @$elm.addClass 'saturday'


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
  cui = new CalendarUI()

  jQuery.getJSON './data.json', (data)->
    for d in data
      tb = new TaskBundle(d.person, d.desc, new Date(d.start), new Date(d.end))
      cui.add_task_bundle tb

  # cui.add_task_bundle new TaskBundle('chilliza', '绘制 mockup', new Date('2014-9-11'), new Date('2014-9-15'))
  # cui.add_task_bundle new TaskBundle('kaid', 'pinyin search', new Date('2014-9-11'), new Date('2014-9-15'))
  # cui.add_task_bundle new TaskBundle('lifei', 'android client', new Date('2014-9-11'), new Date('2014-9-22'))
  # cui.add_task_bundle new TaskBundle('ben7th', 'web ui', new Date('2014-9-12'), new Date('2014-9-22'))
  # cui.add_task_bundle new TaskBundle('ben7th', 'editor ui', new Date('2014-9-12'), new Date('2014-9-22'))


# TODO
  # 子任务
  # 里程碑
  # 后续任务