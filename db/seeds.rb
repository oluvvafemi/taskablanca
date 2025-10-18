puts "== Seeding Taskablanca data =================="

TaskAssignment.delete_all
ProjectMembership.delete_all
Task.delete_all
Project.delete_all
User.delete_all
Organization.delete_all

org1 = Organization.create!(name: "Hotwire Labs")
org2 = Organization.create!(name: "ActiveRecord Studios")

users = User.create!([
  { name: "Ada Lovelace",    email: "ada@hotwirelabs.dev",      organization: org1 },
  { name: "Alan Turing", email: "alan@hotwirelabs.dev",     organization: org1 },
  { name: "Charles Babbage",  email: "charles@hotwirelabs.dev",    organization: org1 },
  { name: "Grace Hopper", email: "grace@activerecord.dev",     organization: org2 },
  { name: "Donald Knuth", email: "donald@activerecord.dev",    organization: org2 },
  { name: "Edsger Dijkstra", email: "edsger@activerecord.dev",    organization: org2 }
])

projects = Project.create!([
  { title: "TurboBoard",        description: "A real-time Kanban powered by Hotwire.", organization: org1 },
  { title: "Stimulus Portal",   description: "A modern UI layer built with Stimulus and Turbo.", organization: org1 },
  { title: "ActiveSchema",      description: "Evolving database schemas with Rails generators.", organization: org2 },
  { title: "RailsRefactor Pro", description: "Refactor legacy apps to follow modern Rails conventions.", organization: org2 }
])

projects.each do |project|
  project_users = users.select { |u| u.organization_id == project.organization_id }.sample(2)
  project.users << project_users
end

statuses = %w[todo in_progress done]

project_tasks = {
  "TurboBoard" => [
    "Implement Turbo Stream updates",
    "Add inline task editing with Turbo Frames",
    "Style Kanban columns with Bootstrap",
    "Broadcast task status changes in real time",
    "Write system tests for task transitions"
  ],
  "Stimulus Portal" => [
    "Create Stimulus controllers for modal dialogs",
    "Refactor project forms to use Turbo Frames",
    "Add search filter for tasks",
    "Integrate FontAwesome icons",
    "Fix flicker issue on task updates"
  ],
  "ActiveSchema" => [
    "Define migration generator templates",
    "Implement reversible migrations",
    "Add validation for column changes",
    "Refactor schema DSL internals",
    "Write unit tests for migration parser"
  ],
  "RailsRefactor Pro" => [
    "Remove deprecated callbacks",
    "Convert legacy ERB templates to Turbo partials",
    "Add RuboCop and fix lint warnings",
    "Extract service objects for background jobs",
    "Improve ActiveRecord query performance"
  ]
}

projects.each do |project|
  project_tasks[project.title].each_with_index do |title, i|
    task = project.tasks.create!(
      title: title,
      description: "Task ##{i + 1} for #{project.title}: #{title.downcase}.",
      status: statuses.sample
    )

    user = project.users[i % project.users.size]
    task.users << user
  end
end

puts "== Seeding completed =========================="
